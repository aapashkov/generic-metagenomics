#!/usr/bin/env python3

from argparse import ArgumentParser
from multiprocessing import Pool, cpu_count
from pathlib import Path
from subprocess import run

parser = ArgumentParser()
parser.add_argument("CMD")
parser.add_argument("-p", type=int, default=1)
cmd, proc = vars(parser.parse_args()).values()
proc = max(min(cpu_count(), proc), 1)

base = Path(__file__).resolve().parent.parent
with open(base/"accessions.txt") as file: accs = [l.strip() for l in file]
def run_cmd(acc): run([cmd, acc])
with Pool(proc) as pool: pool.map(run_cmd, accs)
