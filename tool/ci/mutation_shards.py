#!/usr/bin/env python3
"""Splits the mutation test into shards of about the same number of mutants.

    python3 tool/ci/mutation_shards.py plan <shards> <out dir>
        Writes <out dir>/shard_<i>.xml for i in 0..shards-1. Every file in lib/
        is cut into chunks of about CHUNK lines, a dry run counts the mutants of each
        chunk, and the chunks are packed into shards of about the same size.

    python3 tool/ci/mutation_shards.py total <results dir>
        Sums the "Total tests" and "Undetected Mutations" lines of every
        *.log in <results dir> and fails below the threshold in
        mutation_test.xml.
"""

import glob
import os
import re
import subprocess
import sys
import tempfile

CHUNK = 10
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


def plan(shards, out):
    parts = list(chunks())
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
    target = total / shards
    os.makedirs(out, exist_ok=True)
    # Largest chunks first, each into the lightest shard so far.
    files = [[] for _ in range(shards)]
    sizes = [0] * shards
    for part, count in sorted(zip(parts, counts), key=lambda pc: -pc[1]):
        if count:
            shard = sizes.index(min(sizes))
            files[shard].append(file_xml(*part))
            sizes[shard] += count
    for shard, shard_files in enumerate(files):
        write(out, shard, shard_files)
    print(f"{total} mutants in {shards} shards of about {round(target)}")


def write(out, shard, files):
    with open(os.path.join(out, f"shard_{shard}.xml"), "w") as xml:
        xml.write(config_with("".join(files), threshold=0))


def total(results):
    tests = undetected = 0
    for log in glob.glob(os.path.join(results, "**", "*.log"), recursive=True):
        with open(log) as text:
            content = text.read()
        tests += sum(int(n) for n in re.findall(r"Total tests: (\d+)", content))
        undetected += sum(
            int(n) for n in re.findall(r"Undetected Mutations: (\d+)", content))
    with open(CONFIG) as config:
        threshold = float(re.search(r'failure="(\d+)"', config.read()).group(1))
    detected = 100 * (tests - undetected) / tests if tests else 0
    print(f"{tests - undetected} of {tests} mutants detected, {detected:.2f}%, "
          f"threshold {threshold:g}%")
    if detected < threshold:
        sys.exit(1)


if __name__ == "__main__":
    command = sys.argv[1]
    if command == "plan":
        plan(int(sys.argv[2]), sys.argv[3])
    elif command == "total":
        total(sys.argv[2])
    else:
        sys.exit(__doc__)
