#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# --------------------------------------------------------------
# Classifies reads corresponding to an accession.
# Usage: ./src/docker-run.sh src/classify-reads.sh [accession]
# --------------------------------------------------------------

log () {
  echo "$(date +'%D %T:') ${1}" >&2
}

# Change to project base directory
cd $(dirname $(dirname $(readlink -f $0)))

# Get number of CPUs from config file
cpus=$(cat cpus.conf)

# Create output directories
db="data/databases/krakenDB"
inp="data/reads/trimmed"
out="data/taxonomy/reads"
tmp=${out}"/.tmp-classify-${1}"
mkdir -p ${tmp}
trap "rm -rf ${tmp}" EXIT

# Skip accession if already classified
if [[ -f "${out}/${1}.output.gz" ]]; then
  log "  Skipping ${1} on read level"
else

  output="${tmp}/${1}.output"
  report="${tmp}/${1}.report"

  # Classify reads depending on file type (single or paired)
  if [[ -f "${inp}/${1}_1.fq.gz" ]]; then

    # Paired end read classification
    kraken2 --db ${db} --gzip-compressed --memory-mapping --paired \
      --output ${output} --report ${report} \
      "${inp}/${1}_1.fq.gz" "${inp}/${1}_2.fq.gz" > /dev/null 2>&1

  else

    # Single read classification
    kraken2 --db ${db} --gzip-compressed --memory-mapping \
      --output ${output} --report ${report} \
      "${inp}/${1}.fq.gz" > /dev/null 2>&1
  fi

  # Compress output and report, and move them out of tmp directory
  gzip ${output} ${report}
  mv ${output}.gz ${out}/.
  mv ${report}.gz ${out}/.

  log "  Finished classifying ${1} on read level"
fi

