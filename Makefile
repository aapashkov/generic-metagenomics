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

all: extract-clavibacter annotate-functions annotate-bgcs annotate-amr
.PHONY: all

download-dbs:
> @bash ./src/download-dbs.sh

trim: download-dbs
> @echo $(shell date +'%D %T:') Download and trimming started >&2
> @xargs -a accessions.txt -I {} -P $(cpus) bash ./src/trim.sh {}
> @echo $(shell date +'%D %T:') Download and trimming finished >&2
.PHONY: trim

assemble: trim
> @echo $(shell date +'%D %T:') Assembly started >&2
> @xargs -a accessions.txt -I {} bash ./src/assemble.sh {}
> @echo $(shell date +'%D %T:') Assembly finished >&2
.PHONY: assemble

classify-reads: trim download-dbs
> @echo $(shell date +'%D %T:') Classification started >&2
> @xargs -a accessions.txt -I {} -P $(cpus) bash ./src/classify-reads.sh {}
> @echo $(shell date +'%D %T:') Classification finished >&2
.PHONY: classify-reads

annotate-functions: trim
> @echo $(shell date +'%D %T:') Functional annotation started >&2
> @xargs -a accessions.txt -I {} -P $(cpus) bash ./src/annotate-functions.sh {}
> @echo $(shell date +'%D %T:') Functional annotation finished >&2
.PHONY: annotate-functions

extract-clavibacter: classify-reads
> @echo $(shell date +'%D %T:') Clavibacter extraction started >&2
> @xargs -a accessions.txt -I {} -P $(cpus) bash ./src/extract-clavibacter.sh {}
> @echo $(shell date +'%D %T:') Clavibacter extraction finished >&2
.PHONY: extract-clavibacter

bin: assemble
> @echo $(shell date +'%D %T:') Binning started >&2
> @xargs -a accessions.txt -I {} -P $(cpus) bash ./src/bin.sh {}
> @echo $(shell date +'%D %T:') Binning finished >&2
.PHONY: bin

annotate-bgcs: bin download-dbs
> @echo $(shell date +'%D %T:') BGC annotation started >&2
> @xargs -a accessions.txt -I {} -P $(cpus) bash ./src/annotate-bgcs.sh {}
> @echo $(shell date +'%D %T:') BGC annotation finished >&2
.PHONY: annotate-bgcs

annotate-amr: bin download-dbs
> @echo $(shell date +'%D %T:') AMR annotation started >&2
> @xargs -a accessions.txt -I {} -P $(cpus) bash ./src/annotate-amr.sh {}
> @echo $(shell date +'%D %T:') AMR annotation finished >&2
.PHONY: annotate-amr
