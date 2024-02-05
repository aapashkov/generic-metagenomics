#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# ----------------------------------------------------------------
# Annotate functions with mifaser.
# Usage: ./src/docker-run.sh src/annotate-functions.sh [accession]
# ----------------------------------------------------------------

log () {
  echo "$(TZ=America/Mexico_City date +'%D %T:') ${1}" >&2
}

# Change to project base directory
cd $(dirname $(dirname $(readlink -f $0)))

# Set input and output
inp="data/reads/trimmed"
out="data/functions"
tmp=${out}"/.tmp-${1}"
mkdir -m 775 -p "${tmp}/${1}"
trap "rm -rf ${tmp}" EXIT

# Skip accession if already annotated
if [[ -f "${out}/${1}.tar.gz" ]]; then
  log "  Skipping ${1}"
else

  # Annotate files depending on file type (single or paired)
  if [[ -f "${inp}/${1}_1.fq.gz" ]]; then

    # Paired end read annotation
    seqtk seq -A "${inp}/${1}_1.fq.gz" > "${tmp}/${1}_1.fa"
    seqtk seq -A "${inp}/${1}_2.fq.gz" > "${tmp}/${1}_2.fa"
    mifaser -s 0 -S 0 -q -o "${tmp}/${1}" -d "GS-21-all" \
      -l "${tmp}/${1}_1.fa" "${tmp}/${1}_2.fa"
  else

    # Single read annotation
    seqtk seq -A "${inp}/${1}.fq.gz" > "${tmp}/${1}.fa"
    mifaser -s 0 -S 0 -q -f "${tmp}/${1}.fa" -o "${tmp}/${1}" -d "GS-21-all"
  fi

  # Compress files and move them out of temp directory
  tar -C "${tmp}" -zcf "${tmp}/${1}.tar.gz" "${1}"
  chmod 775 "${tmp}/${1}.tar.gz"
  mv "${tmp}/${1}.tar.gz" "${out}/."

  log "  Finished with ${1}"
fi
