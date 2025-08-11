# Generic metagenomics: A general purpose pipeline for metagenomics analyses (rhizosphere branch)

> [!CAUTION]
> **This pipeline is still experimental**. Use at your own risk.

**Generic metagenomics** is a comprehensive pipeline that automatically
downloads, trims, assembles, classifies, bins, and annotates (almost) any
metagenomic sample available in the SRA database.

### Getting started

1. Install [Docker Engine or Desktop](https://docs.docker.com/engine/install/)
and [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) on your
system.
2. Open a terminal, and run the following commands:

```shell
# 🌎 Clone this repository
git clone https://github.com/aapashkov/generic-metagenomics

# 📌 Change into base directory
cd generic-metagenomics

# ⚡ Run pipeline
docker compose up
```

### Specifying samples

The pipeline processes the SRA accessions listed in the `accessions.txt` file.
Modify it by specifying your samples of interest, one per line. The file already
includes some example accessions for reference purposes.

### Output description

All pipeline outputs are stored in the `data` directory. You should expect a
file structure like the following:

```shell
├── 📁 data/                # Pipeline outputs
│   ├── 📁 amr/             # Genes conferring antibiotic resistance
│   ├── 📁 assemblies/      # Assembled metagenomes
│   ├── 📁 bgcs/            # Predicted biosynthetic gene clusters
│   ├── 📁 bins/            # Metagenomic bins
│   ├── 📁 checks/          # Bin quality checks
│   ├── 📁 databases/       # All required reference databases
│   ├── 📁 functions/       # Functional profiles per sample
│   ├── 📁 reads/           # Metagenomic reads
│   └── 📁 taxonomy/        # Taxonomic assignment
├── 📁 env/                 # Environment definitions
├── 📁 src/                 # Source code
├── 📄 accessions.txt       # SRA accessions list
├── 📄 cpus.conf            # Maximum number of CPUs to use
├── 📄 docker-compose.yml   # Docker execution parameters
├── 📄 Dockerfile           # Docker build definition
├── 📄 Makefile             # Pipeline steps
└── 📄 readme.md            # Documentation
```
