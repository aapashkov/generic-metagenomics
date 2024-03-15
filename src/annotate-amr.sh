#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# ----------------------------------------------------------
# Annotate AMR with RGI.
# Usage: ./src/docker-run.sh src/annotate-amr.sh [accession]
# ----------------------------------------------------------

log () {
  echo "$(TZ=America/Mexico_City date +'%D %T:') ${1}" >&2
}

# Change to project base directory
cd $(dirname $(dirname $(readlink -f $0)))

# Set input and output
inp=$(readlink -f "data/bins")
out=$(readlink -f "data/amr")
tmp="${out}/.tmp-${1}"
rgi="/opt/conda/envs/rgi/bin/rgi"
mkdir -m 775 -p "${tmp}"
trap "rm -rf ${tmp}" EXIT
cd "data/databases"

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

  # Annotate extracted fasta files
  echo "${fastas}" | while read file; do

    base=$(basename "${file}" .fasta)
    "$rgi" main -i "${tmp}/${file}" \
      -o "${tmp}/${1}/${base}" \
      -a DIAMOND \
      -n 1 \
      --include_loose \
      --include_nudge \
      --local --clean \
      --low_quality
    
    rm "${tmp}/${file}"*
    mv "${tmp}/${1}/${base}.txt" "${tmp}/${1}/${base}.tsv"

  done

  # Compress into archive and move it out of temporary directory
  tar -C "${tmp}" -zcf "${tmp}/${1}.tar.gz" "${1}"
  mv "${tmp}/${1}.tar.gz" "${out}/."

  log "  Finished with ${1}"
fi
