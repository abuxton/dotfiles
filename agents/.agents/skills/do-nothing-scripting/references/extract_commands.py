#!/usr/bin/env python3
"""
extract_commands.py — Extract the command sequence from various input formats.

Supported formats (auto-detected):
  cast    — asciinema v2/v3 .cast file (JSON events)
  history — output of the shell `history` command (e.g. "  123  git status")
  text    — plain text file, one command per line

Usage:
    python3 extract_commands.py <file>                    # auto-detect format
    python3 extract_commands.py --format=cast <file>      # force cast format
    python3 extract_commands.py --format=history <file>   # force history format
    python3 extract_commands.py --format=text <file>      # force text format

Output:
    Numbered list of commands to stdout, one per line:
        1  git status
        2  git checkout -b feature/my-branch
        ...
"""

import json
import re
import sys
from pathlib import Path


# Matches common shell prompt endings, capturing the command that follows.
PROMPT_RE = re.compile(
    r"(?:[$%❯>])\s+(.+)$",
    re.MULTILINE,
)

# ANSI escape sequence stripper
ANSI_ESCAPE = re.compile(r"\x1b(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])")

# Matches shell history lines: optional leading whitespace, digits, whitespace, command
HISTORY_RE = re.compile(r"^\s*\d+\s+(.+)$")


def strip_ansi(text: str) -> str:
    return ANSI_ESCAPE.sub("", text)


def extract_via_input_events(events: list) -> list[str]:
    """Reconstruct commands from "i" (stdin) events."""
    buffer = ""
    commands: list[str] = []
    for event in events:
        if len(event) != 3 or event[1] != "i":
            continue
        data: str = event[2]
        for ch in data:
            if ch in ("\r", "\n"):
                cmd = buffer.strip()
                if cmd:
                    commands.append(cmd)
                buffer = ""
            elif ch == "\x7f":  # backspace
                buffer = buffer[:-1]
            else:
                buffer += ch
    if buffer.strip():
        commands.append(buffer.strip())
    return commands


def extract_via_output_events(events: list) -> list[str]:
    """Fall back: reconstruct visible output and grep for prompt lines."""
    output = "".join(
        event[2] for event in events if len(event) == 3 and event[1] == "o"
    )
    output = strip_ansi(output)
    commands: list[str] = []
    for match in PROMPT_RE.finditer(output):
        cmd = match.group(1).strip()
        if cmd:
            commands.append(cmd)
    return commands


def extract_from_cast(lines: list[str]) -> list[str]:
    """Extract commands from an asciinema .cast file."""
    events: list = []
    for line in lines[1:]:   # skip header
        line = line.strip()
        if not line:
            continue
        try:
            events.append(json.loads(line))
        except json.JSONDecodeError:
            continue

    has_input = any(len(e) == 3 and e[1] == "i" for e in events)
    return (
        extract_via_input_events(events)
        if has_input
        else extract_via_output_events(events)
    )


def extract_from_history(lines: list[str]) -> list[str]:
    """Extract commands from shell history output (e.g. `history` or `history N`)."""
    commands: list[str] = []
    for line in lines:
        m = HISTORY_RE.match(line)
        if m:
            cmd = m.group(1).strip()
            if cmd:
                commands.append(cmd)
    return commands


def extract_from_text(lines: list[str]) -> list[str]:
    """Extract commands from a plain text file, one command per line."""
    commands: list[str] = []
    for line in lines:
        line = line.strip()
        if line and not line.startswith("#"):
            commands.append(line)
    return commands


def detect_format(lines: list[str]) -> str:
    """Auto-detect the format of the input file."""
    if not lines:
        return "text"

    # Try to parse first line as JSON with a "version" key → cast format
    try:
        header = json.loads(lines[0])
        if isinstance(header, dict) and "version" in header:
            return "cast"
    except (json.JSONDecodeError, IndexError):
        pass

    # Check if majority of non-empty lines match history format
    non_empty = [line for line in lines if line.strip()]
    if non_empty:
        history_matches = sum(1 for line in non_empty if HISTORY_RE.match(line))
        if history_matches / len(non_empty) >= 0.8:
            return "history"

    return "text"


def parse_args(argv: list[str]) -> tuple[str | None, str | None]:
    """Parse command-line arguments, returning (fmt, path_arg)."""
    fmt = None
    path_arg = None
    for arg in argv[1:]:
        if arg.startswith("--format="):
            fmt = arg.split("=", 1)[1]
        else:
            path_arg = arg
    return fmt, path_arg


def main() -> None:
    fmt, path_arg = parse_args(sys.argv)

    if path_arg is None:
        print(
            "Usage: extract_commands.py [--format=cast|history|text] <file>",
            file=sys.stderr,
        )
        sys.exit(1)

    path = Path(path_arg)
    if not path.exists():
        print(f"ERROR: file not found: {path}", file=sys.stderr)
        sys.exit(1)

    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines:
        print("ERROR: empty file", file=sys.stderr)
        sys.exit(1)

    if fmt is None:
        fmt = detect_format(lines)

    if fmt == "cast":
        commands = extract_from_cast(lines)
    elif fmt == "history":
        commands = extract_from_history(lines)
    elif fmt == "text":
        commands = extract_from_text(lines)
    else:
        print(
            f"ERROR: unknown format: {fmt!r}. Use cast, history, or text.",
            file=sys.stderr,
        )
        sys.exit(1)

    if not commands:
        print(f"No commands found in {fmt} file.", file=sys.stderr)
        sys.exit(1)

    for i, cmd in enumerate(commands, start=1):
        print(f"{i:>3}  {cmd}")


if __name__ == "__main__":
    main()
