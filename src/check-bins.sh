#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# --------------------------------------------------------
# Check bins with checkm and gtdbk.
# Usage: ./src/docker-run.sh src/check-bins.sh [accession]
# --------------------------------------------------------

log () {
  echo "$(TZ=America/Mexico_City date +'%D %T:') ${1}" >&2
}

# Change to project base directory
cd $(dirname $(dirname $(readlink -f $0)))

# Set input and output
inp="data/bins"
out="data/checks"
tmp=${out}"/.tmp-${1}"
mkdir -m 775 -p "${tmp}"
trap "rm -rf ${tmp}" EXIT

# Skip accession if already annotated
if [[ -f "${out}/${1}.tar.gz" ]]; then
  log "  Skipping ${1}"
else

  # Try to extract .fasta files from tar.gz
  fastas=$(tar -C "${tmp}" -vzxf "${inp}/${1}.tar.gz" --wildcards "*.fasta" \
    2> /dev/null || :)

  # Produce empty output if no fasta files are found
  if test -z "${fastas}"; then
    log "  No fasta files found in ${1}, producing empty output"
    touch "${out}/${1}-empty.tar.gz"
    exit 0
  fi

  # Check bins with checkm
  checkm lineage_wf -x fasta --tmpdir "$tmp" \
    "$tmp/$1" "$tmp/$1/checkm" &> /dev/null

  # Assign taxonomy to bins with gtdbtk
  gtdbtk classify_wf --genome_dir "$tmp/$1" --out_dir "$tmp/$1/gtdbtk" \
    --mash_db data/databases/gtdb -x fasta --scratch_dir "$tmp/scratch" \
    --tmpdir "$tmp" &> /dev/null

  # Remove extracted bin files, compress result and move it to output directory
  rm -f "$tmp/$1/"*.fasta
  tar -C "$tmp" -zcf "$tmp/$1.tar.gz" "$1"
  chmod 775 "$tmp/$1.tar.gz"
  mv "$tmp/$1.tar.gz" "$out/."

  log "  Finished with ${1}"
fi
