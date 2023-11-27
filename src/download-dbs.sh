#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# ---------------------------------------------------
# Download required databases (for Kraken 2 and RGI).
# Usage: ./src/docker-run.sh src/download-dbs.sh
# ---------------------------------------------------

log () {
  echo "$(date +'%D %T:') ${1}" >&2
}

# Change to project base directory
cd $(dirname $(dirname $(readlink -f $0)))

# Create output directory
out="data/databases"
tmp=${out}"/.tmp-download-dbs"
mkdir -p ${tmp}
trap "rm -rf ${tmp}" EXIT

# Download Kraken2 database if it wasn't done so already
url="https://genome-idx.s3.amazonaws.com/kraken/k2_standard_20231009.tar.gz"
if [[ -d "${out}/krakenDB" ]]; then
  log "  Skipping Kraken database download"
else
  log "  Downloading Kraken database"
  mkdir -p "${tmp}/krakenDB"
  wget -qO - "${url}" | tar -C "${tmp}/krakenDB" -xzf - 
  mv "${tmp}/krakenDB" "${out}/."
fi

# Download RGI database if it wasn't done so already
url="https://card.mcmaster.ca/download/0/broadstreet-v3.2.8.tar.bz2"
if [[ -d "${out}/localDB" ]]; then
  log "  Skipping CARD download"
else
  log "  Downloading CARD"
  mkdir -p "${tmp}/localDB"
  wget -qO - "${url}" | tar -C "${tmp}/localDB" -xjf - ./card.json 
  mv "${tmp}/localDB" "${out}/."
fi
