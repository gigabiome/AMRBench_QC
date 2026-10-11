# AMRBench_QC: Output

All results are written to the directory given by `--outdir`, with one
sub-directory per tool. `<sample>` is the name from the samplesheet.

## FastQC

`fastqc/`

- `<sample>_1_fastqc.html`, `<sample>_2_fastqc.html`: quality report per read file
- `<sample>_1_fastqc.zip`, `<sample>_2_fastqc.zip`: report data and plots

## fastp

`fastp/`

- `<sample>_1.fastp.fastq.gz`, `<sample>_2.fastp.fastq.gz`: trimmed reads
- `<sample>.fastp.html`, `<sample>.fastp.json`: trimming report
- `<sample>.fastp.log`: log file

## Unicycler

`unicycler/`

- `<sample>.fasta`: assembled contigs
- `<sample>.gfa`: assembly graph
- `<sample>.unicycler.log`: log file

## QUAST

`quast/<sample>/`

- `report.html`, `report.tsv`, `report.txt`: assembly statistics such as contig
  count, total length and N50

## Prokka

`prokka/<sample>/`

- `<sample>.gff`: annotation with sequences
- `<sample>.gbk`: GenBank file
- `<sample>.faa`, `<sample>.ffn`: predicted protein and gene sequences
- `<sample>.tsv`: feature table
- `<sample>.txt`: annotation summary

## MultiQC

`multiqc/`

- `multiqc_report.html`: one report combining FastQC, fastp, QUAST and Prokka
  results for all samples
- `multiqc_data/`: the parsed data behind the report

## Pipeline information

`pipeline_info/`

- `execution_report.html`, `execution_timeline.html`, `execution_trace.txt`:
  Nextflow reports on run time and resource use
