#!/usr/bin/env python3
"""Renders Apple's definition of a popover as a glass popover card.

Usage: quote.py OUT_FILE

The card shares the glass and the palette of the README badges and follows
prefers-color-scheme. Its arrow points down at the demo image.
"""

import sys

from render import REGULAR, STYLE

QUOTE = (
    "A popover is a transient view that appears above other content "
    "when people click or tap a control or interactive area."
)
SOURCE = "Apple Human Interface Guidelines"

SIZE = 17
LINE = 26
SOURCE_SIZE = 12.5
PAD_X = 30
PAD_TOP = 26
PAD_BOTTOM = 24
RADIUS = 20
ARROW_WIDTH = 26
ARROW_HEIGHT = 13
MARGIN = 16
BLUE = "#0a84ff"


def text_width(text, size):
    return sum(REGULAR.get(ch, 640) for ch in text) * size / 1000


def two_lines(text):
    words = text.split()
    split = min(
        range(1, len(words)),
        key=lambda k: abs(
            text_width(" ".join(words[:k]), SIZE)
            - text_width(" ".join(words[k:]), SIZE)
        ),
    )
    return [" ".join(words[:split]), " ".join(words[split:])]


def outline(x0, y0, x1, y1, cx):
    r = RADIUS - 0.5
    tip = y1 + ARROW_HEIGHT
    half = ARROW_WIDTH / 2
    return (
        f"M{x0 + r},{y0} H{x1 - r} A{r},{r} 0 0 1 {x1},{y0 + r} V{y1 - r} "
        f"A{r},{r} 0 0 1 {x1 - r},{y1} H{cx + half} "
        f"C{cx + half - 5},{y1} {cx + 4},{tip - 1.5} {cx + 1.6},{tip - 0.4} "
        f"Q{cx},{tip} {cx - 1.6},{tip - 0.4} "
        f"C{cx - 4},{tip - 1.5} {cx - half + 5},{y1} {cx - half},{y1} "
        f"H{x0 + r} A{r},{r} 0 0 1 {x0},{y1 - r} V{y0 + r} "
        f"A{r},{r} 0 0 1 {x0 + r},{y0} Z"
    )


def card():
    lines = two_lines(QUOTE)
    w = round(max(text_width(line, SIZE) for line in lines) + 2 * PAD_X)
    h = PAD_TOP + len(lines) * LINE + 14 + SOURCE_SIZE + PAD_BOTTOM
    width = w + 2 * MARGIN
    height = round(h + ARROW_HEIGHT + 2 * MARGIN)
    m = MARGIN
    cx = m + w / 2
    path = outline(m + 0.5, m + 0.5, m + w - 0.5, m + h - 0.5, cx)
    quote = "".join(
        f'<text class="v q" x="{cx}" y="{m + PAD_TOP + (i + 1) * LINE - 7}" '
        f'text-anchor="middle">{line}</text>'
        for i, line in enumerate(lines)
    )
    dot_x = cx - (11.5 + text_width(SOURCE, SOURCE_SIZE)) / 2 + 5.5
    source_y = m + PAD_TOP + len(lines) * LINE + 12 + SOURCE_SIZE
    style = (
        f"{STYLE}.q{{font-size:{SIZE}px;font-weight:400;letter-spacing:-.01em}}"
        f".s{{font-size:{SOURCE_SIZE}px}}"
    )
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" '
        f'height="{height}" viewBox="0 0 {width} {height}" role="img" '
        f'aria-label="{QUOTE} {SOURCE}">'
        f"<title>{QUOTE} {SOURCE}</title>"
        f"<style>{style}</style>"
        "<defs>"
        '<linearGradient id="f" x1="0" y1="0" x2="0" y2="1">'
        '<stop offset="0" class="a"/><stop offset="1" class="b"/>'
        "</linearGradient>"
        '<linearGradient id="g" x1="0" y1="0" x2="0" y2="1">'
        '<stop offset="0" class="t"/>'
        '<stop offset=".25" stop-color="#fff" stop-opacity="0"/>'
        "</linearGradient>"
        '<filter id="s" x="-10%" y="-20%" width="120%" height="150%">'
        '<feDropShadow dx="0" dy="6" stdDeviation="7" '
        'flood-color="#141428" flood-opacity=".09"/>'
        '<feDropShadow dx="0" dy="1" stdDeviation="1" '
        'flood-color="#141428" flood-opacity=".08"/>'
        "</filter>"
        "</defs>"
        f'<path d="{path}" fill="url(#f)" class="e" filter="url(#s)"/>'
        f'<rect x="{m + 1.5}" y="{m + 1.5}" width="{w - 3}" height="{h - 3}" '
        f'rx="{RADIUS - 1.5}" fill="none" stroke="url(#g)"/>'
        f"{quote}"
        f'<circle cx="{dot_x:.1f}" cy="{source_y - 4.2:.1f}" r="5.5" '
        f'fill="{BLUE}" class="h"/>'
        f'<circle cx="{dot_x:.1f}" cy="{source_y - 4.2:.1f}" r="3.5" '
        f'fill="{BLUE}"/>'
        f'<text class="l s" x="{dot_x + 11.5:.1f}" y="{source_y:.1f}">'
        f"{SOURCE}</text>"
        "</svg>\n"
    )


if __name__ == "__main__":
    with open(sys.argv[1], "w") as out:
        out.write(card())
