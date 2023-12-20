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

# Create output directory
inp="data/reads/trimmed"
out="data/functions"
tmp=${out}"/.tmp-${1}"
mkdir -p ${out}
trap "rm -rf ${tmp}" EXIT

# Skip accession if already annotated
if [[ -d "${out}/${1}" ]]; then
  log "  Skipping ${1}"
else

  # Annotate files depending on file type (single or paired)
  if [[ -f "${inp}/${1}_1.fq.gz" ]]; then

    # Paired end read annotation
    mifaser -c 1 -q -l "${inp}/${1}_1.fq.gz" "${inp}/${1}_2.fq.gz"  \
      -o "${tmp}" -d "GS-21-all"
  else
    # Single read annotation
    mifaser -c 1 -q -f "${inp}/${1}.fq.gz" -o "${tmp}" -d "GS-21-all"
  fi

  # Make output directory visible
  mv "${tmp}" "${out}/${1}"

  log "  Finished with ${1}"
fi
