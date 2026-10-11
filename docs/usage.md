# AMRBench_QC: Usage

## Samplesheet input

The pipeline takes a comma-separated samplesheet through `--input`. It needs a
header row and three columns:

```csv
sample,fastq_1,fastq_2
SAMPLE_1,/path/to/SAMPLE_1_R1.fastq.gz,/path/to/SAMPLE_1_R2.fastq.gz
SAMPLE_2,/path/to/SAMPLE_2_R1.fastq.gz,/path/to/SAMPLE_2_R2.fastq.gz
```

| Column | Description |
|---|---|
| `sample` | Sample name, used to name all output files. Must be unique and contain no spaces. |
| `fastq_1` | Path or URL to the read 1 FASTQ file. |
| `fastq_2` | Path or URL to the read 2 FASTQ file. |

Relative paths are resolved from the directory the pipeline is launched in.
The run stops with an error if a column is missing, a value is empty, a file
does not exist or a sample name appears more than once.

An example is provided in [`assets/samplesheet.csv`](../assets/samplesheet.csv).

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
