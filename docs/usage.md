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
  QUAST and Prokka.

Both kinds can be mixed in one samplesheet. Columns that are not needed can be
left out, so a samplesheet of reads only needs `sample,fastq_1,fastq_2` and a
samplesheet of assemblies only needs `sample,fasta`.

Relative paths are resolved from the directory the pipeline is launched in.
The run stops with an error if a sample has neither input or both, a file does
not exist, or a sample name appears more than once.

Examples are provided in [`assets/samplesheet.csv`](../assets/samplesheet.csv)
and [`assets/samplesheet_assemblies.csv`](../assets/samplesheet_assemblies.csv).

### Notes on supplied assemblies

Prokka rejects contig names longer than 37 characters. If your FASTA headers
are longer, either shorten them first or let Prokka rename the contigs:

```bash
--prokka_args '--centre X --compliant'
```

This option also drops contigs shorter than 200 bp.

## Running the pipeline

```bash
nextflow run main.nf -profile docker --input samplesheet.csv --outdir results
```

Add `-resume` to continue a run from where it stopped.

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `--input` | none (required) | Path to the samplesheet |
| `--outdir` | `results` | Output directory |
| `--publish_dir_mode` | `copy` | How results are placed in the output directory |
| `--fastp_args` | `''` | Extra options for fastp |
| `--unicycler_args` | `''` | Extra options for Unicycler |
| `--prokka_args` | `''` | Extra options for Prokka, e.g. `'--genus Escherichia --species coli'` |

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
