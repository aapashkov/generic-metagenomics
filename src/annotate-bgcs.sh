#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# ----------------------------------------------------------------
# Annotate reads with mifaser.
# Usage: ./src/docker-run.sh src/annotate-functions.sh [accession]
# ----------------------------------------------------------------

log () {
  echo "$(date +'%D %T:') ${1}" >&2
}

# Change to project base directory
cd $(dirname $(dirname $(readlink -f $0)))

# Set input and output
database="data/databases/antismashDB"
inp="data/bins"
out="data/bgcs"
tmp=${out}"/.tmp-${1}"
mkdir -m 775 -p "${tmp}"
trap "rm -rf ${tmp}" EXIT

# Skip accession if already annotated
if [[ -f "${out}/${1}.tar.gz" ]]; then
  log "  Skipping ${1}"
else
  log "  Annotating BGCs of ${1}"

  # Decompress .fasta files from tar.gz and annotate them
  tar -C "${tmp}" -vzxf "${inp}/${1}.tar.gz" --wildcards "*.fasta" \
    | while read file; do

    base=$(basename "${file}" .fasta)

    antismash -c 1 \
      --output-dir "${tmp}/${1}/${base}" \
      --output-basename "${base}" \
      --genefinding-tool prodigal-m \
      --databases "${database}" \
      "${tmp}/${file}"

  done

  # Compress into archive and move it out of temporary directory
  rm "${tmp}/${1}/"*.fasta
  tar -C "${tmp}/" -zcf "${tmp}/${1}.tar.gz" "${1}"
  mv "${tmp}/${1}.tar.gz" "${out}/."

fi
