#!/usr/bin/env python3
"""Splits the mutation test into shards of about the same number of mutants.

    python3 tool/ci/mutation_shards.py plan <out dir> [<base ref>]
        Writes <out dir>/shard_<i>.xml for every shard with mutants and prints
        the shard numbers as a JSON list. Every file
        in lib/ is cut into chunks of about CHUNK lines, a dry run counts the
        mutants of each chunk, and the chunks are packed into shards of about
        the same size, PER_SHARD mutants each and at most MAX_SHARDS shards.
        With a base ref, only the chunks that touch lines changed since that
        ref are mutated.

    python3 tool/ci/mutation_shards.py total <results dir> [<shards>]
        Sums the "Total tests" and "Undetected Mutations" lines of every
        *.log in <results dir> and fails below the threshold in
        mutation_test.xml. With the JSON list of planned shards it also fails
        when a planned shard left no log with a total.
"""

import glob
import json
import os
import re
import subprocess
import sys
import tempfile

CHUNK = 10
PER_SHARD = 50
MAX_SHARDS = 10
CONFIG = "mutation_test.xml"


def chunks():
    """Chunks of at least CHUNK lines that end after a class member or a
    top-level declaration, so no mutation, some of which match across lines,
    spans two chunks."""
    for path in sorted(glob.glob("lib/**/*.dart", recursive=True)):
        with open(path) as source:
            lines = source.read().splitlines()
        begin = 1
        for number, line in enumerate(lines, start=1):
            ends = line.rstrip() in ("}", "  }", "};", "  };")
            if number - begin + 1 >= CHUNK and ends:
                yield path, begin, number
                begin = number + 1
        if begin <= len(lines):
            yield path, begin, len(lines)


def config_with(files_xml, threshold=None):
    with open(CONFIG) as config:
        text = config.read()
    text = re.sub(r"<files>.*?</files>", f"<files>{files_xml}</files>", text, flags=re.S)
    if threshold is not None:
        text = re.sub(r'failure="\d+"', f'failure="{threshold}"', text)
    return text


def file_xml(path, begin, end):
    return f'<file>{path}<lines begin="{begin}" end="{end}"/></file>'


def changed_lines(base):
    """Line numbers in lib/ added or changed since [base], by file. A deletion
    counts as a change of the line after it."""
    diff = subprocess.run(
        ["git", "diff", "--unified=0", f"{base}...HEAD", "--", "lib/"],
        capture_output=True, text=True, check=True,
    ).stdout
    changed, path = {}, None
    for line in diff.splitlines():
        if line.startswith("+++ "):
            path = line[6:] if line.startswith("+++ b/") else None
        hunk = re.match(r"@@ -\S+ \+(\d+)(?:,(\d+))? @@", line)
        if hunk and path:
            start, count = int(hunk.group(1)), int(hunk.group(2) or 1)
            changed.setdefault(path, set()).update(
                range(start, start + max(count, 1)))
    return changed


def plan(out, base=None):
    parts = list(chunks())
    if base:
        changed = changed_lines(base)
        parts = [
            (path, begin, end) for path, begin, end in parts
            if any(begin <= n <= end for n in changed.get(path, ()))
        ]
    os.makedirs(out, exist_ok=True)
    if not parts:
        print("no Dart changes in lib/ to mutate", file=sys.stderr)
        print("[]")
        return
    with tempfile.TemporaryDirectory() as tmp:
        inputs = []
        for i, part in enumerate(parts):
            name = os.path.join(tmp, f"chunk_{i:04d}.xml")
            with open(name, "w") as xml:
                xml.write(config_with(file_xml(*part)))
            inputs.append(name)
        result = subprocess.run(
            ["dart", "run", "mutation_test", "--dry", "-f", "none", *inputs],
            capture_output=True, text=True, check=False,
        )
    counts = [int(n) for n in re.findall(r" : (\d+) mutations", result.stdout)]
    if len(counts) != len(parts):
        sys.exit(f"expected {len(parts)} counts, got {len(counts)}\n{result.stdout}")

    total = sum(counts)
    shards = max(1, min(MAX_SHARDS, -(-total // PER_SHARD)))
    target = total / shards
    # Largest chunks first, each into the lightest shard so far.
    files = [[] for _ in range(shards)]
    sizes = [0] * shards
    for part, count in sorted(zip(parts, counts), key=lambda pc: -pc[1]):
        if count:
            shard = sizes.index(min(sizes))
            files[shard].append(file_xml(*part))
            sizes[shard] += count
    used = []
    for shard, shard_files in enumerate(files):
        if shard_files:
            write(out, shard, shard_files)
            used.append(shard)
    print(f"{total} mutants in {len(used)} shards of about {round(target)}",
          file=sys.stderr)
    print(json.dumps(used))


def write(out, shard, files):
    with open(os.path.join(out, f"shard_{shard}.xml"), "w") as xml:
        xml.write(config_with("".join(files), threshold=0))


def total(results, planned=None):
    tests = undetected = 0
    reported = set()
    for log in glob.glob(os.path.join(results, "**", "*.log"), recursive=True):
        with open(log) as text:
            content = text.read()
        counts = [int(n) for n in re.findall(r"Total tests: (\d+)", content)]
        if counts:
            shard = re.search(r"shard_(\d+)\.log$", log)
            if shard:
                reported.add(int(shard.group(1)))
        tests += sum(counts)
        undetected += sum(
            int(n) for n in re.findall(r"Undetected Mutations: (\d+)", content))
    missing = sorted(set(json.loads(planned or "[]")) - reported)
    if missing:
        sys.exit(f"no mutation totals from shards {missing}")
    with open(CONFIG) as config:
        threshold = float(re.search(r'failure="(\d+)"', config.read()).group(1))
    if not tests:
        print("no mutants to test")
        return
    detected = 100 * (tests - undetected) / tests
    print(f"{tests - undetected} of {tests} mutants detected, {detected:.2f}%, "
          f"threshold {threshold:g}%")
    if detected < threshold:
        sys.exit(1)


if __name__ == "__main__":
    command = sys.argv[1]
    if command == "plan":
        plan(sys.argv[2], *sys.argv[3:4])
    elif command == "total":
        total(sys.argv[2], *sys.argv[3:4])
    else:
        sys.exit(__doc__)
