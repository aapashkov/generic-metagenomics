#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# -----------------------------------------------------------------
# Extracts Clavibacter reads of an accession.
# Usage: ./src/docker-run.sh src/extract-clavibacter.sh [accession]
# -----------------------------------------------------------------

log () {
  echo "$(TZ=America/Mexico_City date +'%D %T:') ${1}" >&2
}

# Change to project base directory
cd $(dirname $(dirname $(readlink -f $0)))

# Set directories
inp="data/reads/trimmed"
koutput="data/taxonomy/read-level/${1}.output"
kreport="data/taxonomy/read-level/${1}.report"
out="data/reads/extracted/clavibacter"
tmp=${out}"/.tmp-extract-clavibacter-${1}"
mkdir -m 775 -p ${tmp}
trap "rm -rf ${tmp}" EXIT

# Skip accession if already extracted
if compgen -G "${out}/${1}*.fq.gz" > /dev/null; then
  log "  Skipping ${1}"
else

  # Classify reads depending on file type (single or paired)
  if [[ -f "${inp}/${1}_1.fq.gz" ]]; then

    # Paired end read extraction
    extract_kraken_reads.py -t 1573 --fastq-output --include-children \
      -k <(gunzip -c ${koutput}) \
      -r <(gunzip -c ${kreport}) \
      -s ${inp}/${1}_1.fq.gz \
      -s2 ${inp}/${1}_2.fq.gz \
      -o ${tmp}/${1}_1.fq \
      -o2 ${tmp}/${1}_2.fq > /dev/null 2>&1

  else

    # Single read extraction
    extract_kraken_reads.py -t 1573 --fastq-output --include-children \
      -k <(gunzip -c ${koutput}) \
      -r <(gunzip -c ${kreport}) \
      -s ${inp}/${1}.fq.gz \
      -o ${tmp}/${1}.fq > /dev/null 2>&1
  fi

  # Compress output files, and move them out of tmp directory
  gzip ${tmp}/${1}*.fq
  chmod 775 ${tmp}/${1}*.fq.gz
  mv ${tmp}/${1}*.fq.gz ${out}/.

  log "  Finished with ${1}"
fi
