# AMRBench_QC: Usage

## Samplesheet input

The pipeline takes a comma-separated samplesheet through `--input`. It needs a
header row and the columns below:

```csv
sample,fastq_1,fastq_2,fasta
SAMPLE_1,/path/to/SAMPLE_1_R1.fastq.gz,/path/to/SAMPLE_1_R2.fastq.gz,
SAMPLE_2,/path/to/SAMPLE_2_R1.fastq.gz,/path/to/SAMPLE_2_R2.fastq.gz,
SAMPLE_3,,,/path/to/SAMPLE_3.fasta
```

| Column | Description |
|---|---|
| `sample` | Sample name, used to name all output files. Must be unique and contain no spaces. |
| `fastq_1` | Path or URL to the read 1 FASTQ file. |
| `fastq_2` | Path or URL to the read 2 FASTQ file. |
| `fasta` | Optional. Path or URL to an assembled genome, as plain or gzipped FASTA. |

Each sample has either `fastq_1` and `fastq_2`, or `fasta`:

- Samples with reads run through every step.
- Samples with a `fasta` skip FastQC, fastp and Unicycler, and go straight to
  the assembly-level steps: QUAST, CheckM2, Prokka and Bakta.

Both kinds can be mixed in one samplesheet. Columns that are not needed can be
left out, so a samplesheet of reads only needs `sample,fastq_1,fastq_2` and a
samplesheet of assemblies only needs `sample,fasta`.

Relative paths are resolved from the directory the pipeline is launched in.
The run stops with an error if a sample has neither input or both, a file does
not exist, or a sample name appears more than once.

Examples are provided in [`assets/samplesheet.csv`](../assets/samplesheet.csv)
and [`assets/samplesheet_assemblies.csv`](../assets/samplesheet_assemblies.csv).

### Notes on supplied assemblies

Gzipped FASTA files are decompressed automatically.

Prokka rejects contig names longer than 37 characters. If your FASTA headers
are longer, either shorten them first or let Prokka rename the contigs:

```bash
--prokka_args '--centre X --compliant'
```

This option also drops contigs shorter than 200 bp.

## Running the pipeline

```bash
nextflow run main.nf -profile singularity --input samplesheet.csv --outdir results
```

Add `-resume` to continue a run from where it stopped.

## Databases

### Automatic download

If no database paths are given, the pipeline downloads what it needs on the
first run into `--db_dir` (default `databases/` in the launch directory). Later
runs launched with the same `--db_dir` find the databases there and skip the
download.

| Database | Size | Stored as |
|---|---|---|
| Bakta `full` | About 30 GB to download, about 70 GB on disk | `databases/bakta_db_full/` |
| Bakta `light` | About 1.5 GB to download, about 3.5 GB on disk | `databases/bakta_db_light/` |
| CheckM2 | About 1.7 GB to download | `databases/checkm2_db.dmnd` |

The download steps are ordinary pipeline jobs, so the nodes they run on need
internet access.

### Using existing databases

If the compute nodes are offline, or you already have the databases, pass
their locations:

```bash
nextflow run main.nf -profile singularity \
    --input samplesheet.csv \
    --bakta_db /path/to/bakta/db \
    --checkm2_db /path/to/CheckM2_database/uniref100.KO.1.dmnd
```

- `--bakta_db` is the database directory itself, the one containing
  `bakta.db` and `version.json`. It must match the Bakta version the pipeline
  runs (1.12, database schema 6) and must have its AMRFinderPlus database set
  up, which `bakta_db download` does for you.
- `--checkm2_db` is the DIAMOND file, or the directory holding it.

To fetch them by hand on a node with internet access:

```bash
bakta_db download --output /path/to/bakta --type full
```

```bash
wget https://zenodo.org/records/14897628/files/checkm2_database.tar.gz && tar -xzf checkm2_database.tar.gz
```

### Bakta and AMRFinderPlus

Bakta runs AMRFinderPlus internally as part of annotating each predicted
protein, so resistance genes are named in the Bakta annotation. It does not
write a separate AMRFinderPlus report and does not screen for resistance point
mutations.

## Skipping Prokka

Prokka and Bakta both run by default. To annotate with Bakta only:

```bash
nextflow run main.nf -profile singularity --input samplesheet.csv --skip_prokka
```

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `--input` | none (required) | Path to the samplesheet |
| `--outdir` | `results` | Output directory |
| `--publish_dir_mode` | `copy` | How results are placed in the output directory |
| `--skip_prokka` | `false` | Do not run Prokka |
| `--bakta_db` | none | Existing Bakta database directory |
| `--bakta_db_type` | `full` | Database to download when `--bakta_db` is not set: `full` or `light` |
| `--checkm2_db` | none | Existing CheckM2 database (`.dmnd` file or the directory holding it) |
| `--db_dir` | `databases` | Where downloaded databases are kept |
| `--fastp_args` | `''` | Extra options for fastp |
| `--unicycler_args` | `''` | Extra options for Unicycler |
| `--prokka_args` | `''` | Extra options for Prokka, e.g. `'--genus Escherichia --species coli'` |
| `--bakta_args` | `''` | Extra options for Bakta, e.g. `'--genus Escherichia --species coli'` |

Bakta is run with `--keep-contig-headers`, so contig names match those in the
assembly and in the QUAST and Prokka output.

## Profiles

| Profile | Description |
|---|---|
| `docker` | Run each tool in a Docker container |
| `arm` | Docker on Apple Silicon, running the x86 containers under emulation |
| `singularity` | Run each tool in a Singularity container |
| `apptainer` | Run each tool in an Apptainer container |
| `conda` | Create a conda environment per tool |
| `test` | Small public dataset with reduced resources; combine with one of the above |

## Resources

Default CPU, memory and time requests are set per process label in
[`conf/base.config`](../conf/base.config). To change them, edit that file or
supply your own config with `-c custom.config`:

```groovy
process {
    withName: UNICYCLER {
        cpus   = 16
        memory = 32.GB
    }
}
```
