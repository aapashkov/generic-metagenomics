#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# --------------------------------------------------------------
# Classifies reads and assemblies corresponding to an accession.
# Usage: ./src/docker-run.sh src/classify.sh [accession]
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
inp_reads="data/reads/trimmed"
inp_assemblies="data/assemblies/complete"
out_reads="data/taxonomy/reads"
out_assemblies="data/taxonomy/assemblies"
tmp_reads=${out_reads}"/.tmp-classify-${1}"
tmp_assemblies=${out_assemblies}"/.tmp-classify-${1}"
mkdir -p ${tmp_reads} ${tmp_assemblies}
trap "rm -rf ${tmp_reads} ${tmp_assemblies}" EXIT

# Read level classification

# Skip accession if already classified
if [[ -f "${out_reads}/${1}.output.gz" ]]; then
  log "  Skipping ${1} on read level"
else

  output="${tmp_reads}/${1}.output"
  report="${tmp_reads}/${1}.report"

  # Classify reads depending on file type (single or paired)
  if [[ -f "${inp_reads}/${1}_1.fq.gz" ]]; then

    # Paired end read classification
    kraken2 --db ${db} --gzip-compressed --memory-mapping --paired \
      --output ${output} --report ${report} \
      "${inp_reads}/${1}_1.fq.gz" "${inp_reads}/${1}_2.fq.gz" > /dev/null 2>&1

  else

    # Single read classification
    kraken2 --db ${db} --gzip-compressed --memory-mapping \
      --output ${output} --report ${report} \
      "${inp_reads}/${1}.fq.gz" > /dev/null 2>&1
  fi

  # Compress output and report, and move them out of tmp directory
  gzip ${output} ${report}
  mv ${output}.gz ${out_reads}/.
  mv ${report}.gz ${out_reads}/.

  log "  Finished classifying ${1} on read level"
fi

# Assembly level classification

# Skip accession if already classified
if [[ -f "${out_assemblies}/${1}.output.gz" ]]; then
  log "  Skipping ${1} on assembly level"
else

  output="${tmp_assemblies}/${1}.output"
  report="${tmp_assemblies}/${1}.report"

  # Paired end read classification
  kraken2 --db ${db} --gzip-compressed --memory-mapping \
    --output ${output} --report ${report} \
    "${inp_assemblies}/${1}.fa.gz" > /dev/null 2>&1

  # Compress output and report, and move them out of tmp directory
  gzip ${output} ${report}
  mv ${output}.gz ${out_assemblies}/.
  mv ${report}.gz ${out_assemblies}/.

  log "  Finished classifying ${1} on assembly level"
fi
