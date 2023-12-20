#!/usr/bin/env python3

from pathlib import Path
from subprocess import run
import sys

base = Path(__file__).resolve().parent.parent
cmd = sys.argv[1]
with open(base/"accessions.txt") as file: accs = [l.strip() for l in file]
for acc in accs: run([cmd, acc])
