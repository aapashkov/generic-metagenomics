#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# --------------------------------------------------------------------
# Stop all running rhizosphere containers and remove files produced by
# unfinished commands.
# Usage: ./src/docker-stop.sh
# --------------------------------------------------------------------

name="rhizosphere"

# Change to project base directory
cd $(dirname $(dirname $(readlink -f $0)))

# Kill Docker containers if running and remove all .tmp-* directories
if docker inspect $(docker ps -qf name=$name-*) > /dev/null 2>&1; then
  docker kill $(docker ps -qf name=$name-*)
  bash ./src/docker-run.sh \
    find data -type d -name '.tmp-*' -prune -exec rm -rf {} +
fi
