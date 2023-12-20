#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# ------------------------------------------------------
# Assembles files corresponding to an accession.
# Usage: ./src/docker-run.sh src/assemble.sh [accession]
# ------------------------------------------------------

log () {
  echo "$(date +'%D %T:') ${1}" >&2
}

# Change to project base directory
cd $(dirname $(dirname $(readlink -f $0)))

# Get number of CPUs from config file
cpus=$(cat cpus.conf)

# Set input and output
inp="data/reads/trimmed"
out="data/assemblies/complete"
tmp=${out}"/.tmp-assemble-${1}"
mkdir -m 775 -p ${tmp}
trap "rm -rf ${tmp}" EXIT

# Skip accession if already assembled
if [[ -f "${out}/${1}.fa.gz" ]]; then
  log "  Skipping ${1}"
else
  log "  Assembling ${1}"

  # Assemble reads depending on file type (single or paired)
  if [[ -f "${inp}/${1}_1.fq.gz" ]]; then

    # Paired end assembly
    megahit -1 "${inp}/${1}_1.fq.gz" -2 "${inp}/${1}_2.fq.gz" -t ${cpus} \
      -o "${tmp}/assembly" --tmp-dir "${tmp}" > /dev/null 2>&1
  else

    # Single assembly
    megahit -r "${inp}/${1}.fq.gz" -t ${cpus} -o "${tmp}/assembly" \
      --tmp-dir "${tmp}" > /dev/null 2>&1
  fi

  # Compress assembly file and move it out of tmp directory
  pigz -p ${cpus} "${tmp}/assembly/final.contigs.fa"
  chmod 775 "${tmp}/assembly/final.contigs.fa.gz"
  mv "${tmp}/assembly/final.contigs.fa.gz" "${out}/${1}.fa.gz"
fi
