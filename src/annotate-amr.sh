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

  # Decompress .fasta files from tar.gz and annotate them
  tar -C "${tmp}" -vzxf "${inp}/${1}.tar.gz" --wildcards "*.fasta" \
    | while read file; do

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
