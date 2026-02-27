#!/usr/bin/env python3
"""
trim_cast.py — Trim an asciinema v3 .cast file in-place.

Keeps:
  - Line 1 (the JSON header) always
  - All event lines whose output contains "start here" up to (but not
    including) the line containing "end here"

Usage:
    python3 trim_cast.py <path/to/file.cast>
"""

import json
import sys
from pathlib import Path


def trim_cast(path: Path) -> None:
    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines:
        print(f"ERROR: {path} is empty", file=sys.stderr)
        sys.exit(1)

    header = lines[0]          # Always retained
    events = lines[1:]         # Remaining event lines

    inside = False
    kept: list[str] = []

    for line in events:
        if not line.strip():
            continue
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue

        # Events are [timestamp, type, data]
        if len(event) != 3 or event[1] != "o":
            continue

        data: str = event[2]

        if not inside:
            if "start here" in data:
                inside = True
            continue  # Skip lines before (and including) the start marker

        if "end here" in data:
            break      # Stop before (and excluding) the end marker

        kept.append(line)

    output = "\n".join([header] + kept) + "\n"
    path.write_text(output, encoding="utf-8")
    print(f"Trimmed {path}: {len(kept)} events retained.")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: trim_cast.py <file.cast>", file=sys.stderr)
        sys.exit(1)

    cast_path = Path(sys.argv[1])
    if not cast_path.exists():
        print(f"ERROR: file not found: {cast_path}", file=sys.stderr)
        sys.exit(1)

    trim_cast(cast_path)
