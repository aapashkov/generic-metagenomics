#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# ----------------------------------------------
# Download required databases.
# Usage: ./src/docker-run.sh src/download-dbs.sh
# ----------------------------------------------

log () {
  echo "$(date +'%D %T:') ${1}" >&2
}

# Change to project base directory
cd $(dirname $(dirname $(readlink -f $0)))

# Create output directory
out="data/databases"
tmp=${out}"/.tmp-download-dbs"
mkdir -m 775 -p ${tmp}
trap "rm -rf ${tmp}" EXIT

# Download Kraken2 database if it wasn't done so already
if [[ -d "${out}/krakenDB" ]]; then
  log "  Skipping Kraken database download"
else
  log "  Downloading Kraken database"
  mkdir -p "${tmp}/krakenDB"
  url="https://genome-idx.s3.amazonaws.com/kraken/k2_standard_20231009.tar.gz"
  wget -qO - "${url}" | tar -C "${tmp}/krakenDB" -xzf - 
  chmod -R 775 "${tmp}/krakenDB"
  mv "${tmp}/krakenDB" "${out}/."
fi

# Download antiSMASH databases if it wasn't done so already
if [[ -d "${out}/antismashDB" ]]; then
  log "  Skipping antiSMASH database download"
else
  log "  Downloading antiSMASH database"
  mkdir -p "${tmp}/antismashDB"
  download-antismash-databases --database-dir "${tmp}/antismashDB" > /dev/null 2>&1
  chmod -R 775 "${tmp}/antismashDB"
  mv "${tmp}/antismashDB" "${out}/."
fi

# Download CARD if it wasn't done so already
if [[ -f "${out}/localDB/card.json" ]]; then
  log "  Skipping CARD download"
else
  log "  Downloading CARD"
  current=$(pwd)
  cd "${tmp}"
  url="https://card.mcmaster.ca/download/0/broadstreet-v3.2.8.tar.bz2"
  wget -qO - "${url}" | tar -xjf - ./card.json
  micromamba run -n rgi rgi load --local -i card.json
  rm card.json
  mv localDB "${current}/${out}/."
  cd "${current}"
fi

# Download CheckM database if it wasn't done so already
if [[ -d "${out}/checkmDB" ]]; then
  log "  Skipping CheckM database download"
else
  log "  Downloading CheckM database"
  mkdir -p "${tmp}/checkmDB"
  url="https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz"
  wget -qO - "${url}" | tar -C "${tmp}/checkmDB" -xzf - 
  chmod -R 775 "${tmp}/checkmDB"
  mv "${tmp}/checkmDB" "${out}/."
fi

# Download GDTB if it wasn't done so already
if [[ -d "${out}/GTDB" ]]; then
  log "  Skipping GTDB download"
else
  log "  Downloading GTDB"
  url="https://data.ace.uq.edu.au/public/gtdb/data/releases/release220/220.0/auxillary_files/gtdbtk_package/full_package/gtdbtk_r220_data.tar.gz"
  wget -qO - "${url}" | tar -C "${tmp}" -xzf - 
  chmod -R 775 "${tmp}/release220"
  mv "${tmp}/release220" "${out}/GTDB"
fi
