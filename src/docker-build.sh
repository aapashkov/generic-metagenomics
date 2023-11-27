#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# -----------------------------------------
# Build aapashkov/rhizosphere Docker image.
# Usage: ./src/docker-build.sh
# -----------------------------------------

image="aapashkov/rhizosphere"

# Change to project base directory
cd $(dirname $(dirname $(readlink -f $0)))

# Build docker image if it doesn't exist
if ! docker image inspect $image > /dev/null 2>&1; then
  echo "Building Docker image" >&2
  docker build -qt $image .
fi
