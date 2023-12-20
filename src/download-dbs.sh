#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# ---------------------------------------------------------
# Download required databases (for Kraken 2 and antismash).
# Usage: ./src/docker-run.sh src/download-dbs.sh
# ---------------------------------------------------------

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
url="https://genome-idx.s3.amazonaws.com/kraken/k2_standard_20231009.tar.gz"
if [[ -d "${out}/krakenDB" ]]; then
  log "  Skipping Kraken database download"
else
  log "  Downloading Kraken database"
  mkdir -p "${tmp}/krakenDB"
  wget -qO - "${url}" | tar -C "${tmp}/krakenDB" -xzf - 
  chmod -R 775 "${tmp}/krakenDB"
  mv "${tmp}/krakenDB" "${out}/."
fi
