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
inp="data/reads/trimmed"
out="data/functions"
tmp=${out}"/.tmp-${1}"
mkdir -m 775 -p ${out}
trap "rm -rf ${tmp}" EXIT

# Skip accession if already annotated
if [[ -d "${out}/${1}.tar.gz" ]]; then
  log "  Skipping ${1}"
else
  log "  Annotating functions of ${1}"

  # Annotate files depending on file type (single or paired)
  if [[ -f "${inp}/${1}_1.fq.gz" ]]; then

    # Paired end read annotation
    mifaser -s 0 -S 0 -q -o "${tmp}" -d "GS-21-all" \
      -l "${inp}/${1}_1.fq.gz" "${inp}/${1}_2.fq.gz"
  else
    # Single read annotation
    mifaser -s 0 -S 0 -q -f "${inp}/${1}.fq.gz" -o "${tmp}" -d "GS-21-all"
  fi

  # Compress files and move them out of temp directory
  mkdir -p "${tmp}/${1}"
  ls -p "${tmp}/"* | grep -v / | xargs -I {} mv {} "${tmp}/${1}/."
  tar -C "${tmp}" -zcf "${tmp}/${1}.tar.gz" "${1}"
  chmod 775 "${tmp}/${1}.tar.gz"
  mv "${tmp}/${1}.tar.gz" "${out}/."
fi
