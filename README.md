<h1 align="center">AMRBench_QC</h1>

<p align="center">
  Read QC, assembly and gene prediction for bacterial genomes
</p>

<p align="center">
  <a href="https://www.nextflow.io/"><img alt="Nextflow" src="https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A524.04.0-23aa62.svg"></a>
  <a href="https://www.docker.com/"><img alt="Run with Docker" src="https://img.shields.io/badge/run%20with-docker-0db7ed?logo=docker&logoColor=white"></a>
  <a href="https://sylabs.io/docs/"><img alt="Run with Singularity" src="https://img.shields.io/badge/run%20with-singularity-1d355c.svg"></a>
  <a href="https://docs.conda.io/en/latest/"><img alt="Run with conda" src="https://img.shields.io/badge/run%20with-conda-3EB049?logo=anaconda&logoColor=white"></a>
</p>

<p align="center">
  <sub>Built with</sub>
  <br>
  <a href="https://www.nextflow.io/">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://github.com/nextflow-io/trademark/blob/master/nextflow-logo-bg-dark.png?raw=true">
      <img alt="Nextflow" width="240" src="https://github.com/nextflow-io/trademark/blob/master/nextflow-logo-bg-light.png?raw=true">
    </picture>
  </a>
</p>

---

## Introduction

**AMRBench_QC** takes paired-end Illumina reads from one or more bacterial
genomes and produces quality-checked reads, an assembly and an annotated set of
genes for each sample, plus a single summary report.

Genomes that are already assembled can be supplied as FASTA files. These skip
read QC and assembly and go straight to assembly QC and gene prediction.

## Pipeline summary

```mermaid
flowchart LR
    A[/reads<br>fastq_1, fastq_2/] --> B[FastQC<br>raw read QC]
    A --> C[fastp<br>trimming]
    C --> D[Unicycler<br>assembly]
    H[/assembled genome<br>fasta/] --> E
    H --> F
    D --> E[QUAST<br>assembly QC]
    D --> F[Prokka<br>gene prediction]
    B --> G[MultiQC<br>summary report]
    C --> G
    E --> G
    F --> G
```

| Step | Tool | Purpose |
|---|---|---|
| 1 | [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) | Quality report on the raw reads |
| 2 | [fastp](https://github.com/OpenGene/fastp) | Adapter and quality trimming |
| 3 | [Unicycler](https://github.com/rrwick/Unicycler) | Genome assembly |
| 4 | [QUAST](https://quast.sourceforge.net/) | Assembly statistics |
| 5 | [Prokka](https://github.com/tseemann/prokka) | Gene prediction and annotation |
| 6 | [MultiQC](https://multiqc.info/) | One report combining all of the above |

## Quick start

1. Install [Nextflow](https://www.nextflow.io/docs/latest/install.html)
   (`>=24.04.0`) and one of Docker, Singularity/Apptainer or conda.

2. Test the pipeline on a small public dataset:

   ```bash
   nextflow run main.nf -profile test,docker --outdir results
   ```

3. Prepare a samplesheet with your own data:

   ```csv
   sample,fastq_1,fastq_2
   SAMPLE_1,/path/to/SAMPLE_1_R1.fastq.gz,/path/to/SAMPLE_1_R2.fastq.gz
   SAMPLE_2,/path/to/SAMPLE_2_R1.fastq.gz,/path/to/SAMPLE_2_R2.fastq.gz
   ```

4. Run the pipeline:

   ```bash
   nextflow run main.nf -profile docker --input samplesheet.csv --outdir results
   ```

Add `-resume` to continue a run from where it stopped.

## Samplesheet

| Column | Description |
|---|---|
| `sample` | Sample name, used to name all output files. Must be unique and contain no spaces. |
| `fastq_1` | Path or URL to the read 1 FASTQ file |
| `fastq_2` | Path or URL to the read 2 FASTQ file |
| `fasta` | Optional. Path or URL to an assembled genome (plain or gzipped FASTA) |

Each sample has either `fastq_1` and `fastq_2`, or `fasta`. Reads and
assemblies can be mixed in one samplesheet.

### Starting from assembled genomes

To run only assembly QC and gene prediction, list the assemblies in the
`fasta` column. The read columns can be left out entirely:

```csv
sample,fasta
SAMPLE_1,/path/to/SAMPLE_1.fasta
SAMPLE_2,/path/to/SAMPLE_2.fasta
```

```bash
nextflow run main.nf -profile docker --input samplesheet.csv --outdir results
```

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `--input` | none (required) | Path to the samplesheet |
| `--outdir` | `results` | Output directory |
| `--fastp_args` | `''` | Extra options for fastp |
| `--unicycler_args` | `''` | Extra options for Unicycler |
| `--prokka_args` | `''` | Extra options for Prokka, e.g. `'--genus Escherichia --species coli'` |

## Profiles

| Profile | Description |
|---|---|
| `docker` | Run each tool in a Docker container |
| `arm` | Docker on Apple Silicon |
| `singularity` | Run each tool in a Singularity container |
| `apptainer` | Run each tool in an Apptainer container |
| `conda` | Create a conda environment per tool |
| `test` | Small public dataset; combine with one of the above |

## Output

| Folder | Contents |
|---|---|
| `fastqc/` | Quality reports for the raw reads |
| `fastp/` | Trimmed reads and trimming reports |
| `unicycler/` | Assembled contigs (`<sample>.fasta`) and assembly graph |
| `quast/` | Assembly statistics per sample |
| `prokka/` | Annotation per sample (GFF, GenBank, protein and gene FASTA) |
| `multiqc/` | `multiqc_report.html`, the summary of all samples |
| `pipeline_info/` | Nextflow run time and resource reports |

## Documentation

- [Usage](docs/usage.md): samplesheet format, parameters, profiles and resources
- [Output](docs/output.md): every file the pipeline produces

## Repository layout

| Path | Contents |
|---|---|
| `main.nf` | Entry point |
| `nextflow.config` | Default parameters and profiles |
| `workflows/` | The main workflow |
| `subworkflows/local/` | Samplesheet parsing and validation |
| `modules/local/` | One process per tool |
| `conf/` | Resource, per-module and test configuration |
| `assets/` | Example samplesheets and the MultiQC config |
| `docs/` | Usage and output documentation |

## Citations

If you use this pipeline, please cite the tools it runs. References are listed
in [CITATIONS.md](CITATIONS.md).

---

<sub>Nextflow® is a registered trademark of Seqera Labs, S.L. This pipeline is
built with Nextflow and is not affiliated with or endorsed by the Nextflow
project.</sub>
