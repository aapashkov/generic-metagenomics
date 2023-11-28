SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

file := cpus.conf
cpus := $(shell cat ${file})

ifeq ($(origin .RECIPEPREFIX), undefined)
  $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
endif
.RECIPEPREFIX = >

# Complete pipeline, simply run "make"
all: annotate-functions
.PHONY: all


# Docker management rules
build:
> ./src/docker-build.sh
.PHONY: build

rmi:
> docker rmi aapashkov/rhizosphere
.PHONY: rmi

run: build
> ./src/docker-run.sh
.PHONY: run

stop:
> ./src/docker-stop.sh
.PHONY: stop


# Pipeline steps
download-dbs: build
> ./src/docker-run.sh src/download-dbs.sh

trim: build
> @echo $(shell date +'%D %T:') Download and trimming started >&2
> ./src/docker-run.sh rush -i accessions.txt -j $(cpus) ./src/trim.sh {}
> @echo $(shell date +'%D %T:') Download and trimming finished >&2
.PHONY: trim

assemble: trim
> @echo $(shell date +'%D %T:') Assembly started >&2
> ./src/docker-run.sh rush -i accessions.txt -j 1 ./src/assemble.sh {}
> @echo $(shell date +'%D %T:') Assembly finished >&2
.PHONY: assemble

classify: assemble download-dbs
> @echo $(shell date +'%D %T:') Classification started >&2
> ./src/docker-run.sh rush -i accessions.txt -j $(cpus) ./src/classify.sh {}
> @echo $(shell date +'%D %T:') Classification finished >&2
.PHONY: classify

annotate-functions: trim
> @echo $(shell date +'%D %T:') Functional annotation started >&2
> ./src/docker-run.sh rush -i accessions.txt -j $(cpus) ./src/annotate-functions.sh {}
> @echo $(shell date +'%D %T:') Functional annotation finished >&2
.PHONY: annotate-functions
