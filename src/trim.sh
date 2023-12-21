#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# ------------------------------------------------------
# Download and trim files corresponding to an accession.
# Usage: ./src/docker-run.sh src/trim.sh [accession]
# ------------------------------------------------------

log () {
  echo "$(date +'%D %T:') ${1}" >&2
}

# Change to project base directory
cd $(dirname $(dirname $(readlink -f $0)))

# Get number of CPUs from config file
cpus=$(cat cpus.conf)
mcpus=$(expr ${cpus} / 4 + 1) # mifaser cpus

# Set input and output
out="data/reads/trimmed"
tmp=${out}"/.tmp-trim-${1}"
mkdir -m 775 -p ${out}
trap "rm -rf ${tmp}" EXIT

# Skip accession if already downloaded and trimmed
if compgen -G "${out}/${1}*.fq.gz" > /dev/null; then
  log "  Skipping ${1}"
else
  # Download accession files
  log "  Downloading ${1}"
  fasterq-dump -e ${cpus} -q -O ${tmp} -t ${tmp} ${1} > /dev/null 2>&1

  log "  Trimming ${1}"

  # Trim files depending on file type (single or paired)
  if [[ -f "${tmp}/${1}_1.fastq" ]]; then

    # Paired end mode trimming
    trim_galore --length 40 -o ${tmp} --basename ${1} --paired --gzip \
      -j ${mcpus} "${tmp}/${1}_1.fastq" "${tmp}/${1}_2.fastq" > /dev/null 2>&1
    chmod 775 "${tmp}/${1}_val_1.fq.gz"
    chmod 775 "${tmp}/${1}_val_2.fq.gz"
    mv "${tmp}/${1}_val_1.fq.gz" "${out}/${1}_1.fq.gz"
    mv "${tmp}/${1}_val_2.fq.gz" "${out}/${1}_2.fq.gz"
  else

    # Single mode trimming
    trim_galore --length 40 -o ${tmp} --basename ${1} --gzip -j ${mcpus} \
      "${tmp}/${1}.fastq" > /dev/null 2>&1
    chmod 775 "${tmp}/${1}_trimmed.fq.gz"
    mv "${tmp}/${1}_trimmed.fq.gz" "${out}/${1}.fq.gz"
  fi
fi
