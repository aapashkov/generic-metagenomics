#!/usr/bin/env python3

from pathlib import Path

base = Path(__file__).resolve().parent.parent

result = set(
    map(
        lambda x: x.name[:-8] if "_" in x.name else x.name[:-6],
        (base/"data/reads/trimmed").glob("*")
    )
)

print(*sorted(result), sep="\n")
