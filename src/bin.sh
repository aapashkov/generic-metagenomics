#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# -------------------------------------------------
# Bins metagenomic assemblies by accession
# Usage: ./src/docker-run.sh src/bin.sh [accession]
# -------------------------------------------------

log () {
  echo "$(date +'%D %T:') ${1}" >&2
}

# Change to project base directory
cd $(dirname $(dirname $(readlink -f $0)))

# Get number of CPUs from config file
cpus=$(cat cpus.conf)

# Set input and output
assemblies="data/assemblies/complete"
reads="data/reads/trimmed"
out="data/bins"
tmp=${out}"/.tmp-bin-${1}"
mkdir -m 775 -p ${tmp}
trap "rm -rf ${tmp}" EXIT

# Skip accession if already binned
if [[ -f "${out}/${1}.tar.gz" ]]; then
  log "  Skipping ${1}"
else

  log "  Binning ${1}"

  # Perform binning depending on read file type (single or paired)
  if [[ -f "${reads}/${1}_1.fq.gz" ]]; then

    # Paired end binning
    run_MaxBin.pl -contig "${assemblies}/${1}.fa.gz" \
      -out "${tmp}/${1}" \
      -reads "${reads}/${1}_1.fq.gz" \
      -reads2 "${reads}/${1}_2.fq.gz" > /dev/null 2>&1 || true
  else

    # Single binning
    run_MaxBin.pl -contig "${assemblies}/${1}.fa.gz" \
      -out "${tmp}/${1}" \
      -reads "${reads}/${1}.fq.gz" > /dev/null 2>&1 || true
  fi

  # Create and compress output directory
  mkdir -p "${tmp}/${1}"
  mv ${tmp}/${1}.* "${tmp}/${1}/."
  tar -C "${tmp}" -czf "${tmp}/${1}.tar.gz" "${1}"
  chmod 775 "${tmp}/${1}.tar.gz"
  mv "${tmp}/${1}.tar.gz" "${out}/."
fi
