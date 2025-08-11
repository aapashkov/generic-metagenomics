#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# -----------------------------------------------------------------
# Convenience script to run the aapashkov/rhizosphere Docker image.
# Usage:
#   - Interactive mode: ./src/docker-run.sh
#   - Run command: ./src/docker-run.sh [COMMAND]
# -----------------------------------------------------------------

# Change to project base directory
cd $(dirname $(dirname $(readlink -f $0)))
name="rhizosphere-$$$RANDOM"
echo $name >&2

# Run in interactive mode if no command was passed
# shellcheck disable=SC2199
if [[ -z $@ ]]; then
  docker run --name $name -u "mambauser:$(id -g)" --rm \
    -itv "$(pwd):/home/mnt" "aapashkov/rhizosphere"

# Else, run command as specified
else
  # shellcheck disable=SC2068
  docker run --name $name -u "mambauser:$(id -g)" --rm \
    -v "$(pwd):/home/mnt" "aapashkov/rhizosphere" $@
fi
