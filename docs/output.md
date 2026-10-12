# AMRBench_QC: Output

All results are written to the directory given by `--outdir`, with one
sub-directory per tool. `<sample>` is the name from the samplesheet.

Samples supplied as assembled genomes have no FastQC, fastp or Unicycler
output.

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

## CheckM2

`checkm2/<sample>/`

- `quality_report.tsv`: completeness, contamination, genome size, GC content
  and coding density
- `checkm2.log`, `diamond_output/`, `protein_files/`: log and intermediate files

## Prokka

`prokka/<sample>/` (absent when run with `--skip_prokka`)

- `<sample>.gff`: annotation with sequences
- `<sample>.gbk`: GenBank file
- `<sample>.faa`, `<sample>.ffn`: predicted protein and gene sequences
- `<sample>.tsv`: feature table
- `<sample>.txt`: annotation summary

## Bakta

`bakta/<sample>/`

- `<sample>.gff3`: annotation with sequences
- `<sample>.gbff`, `<sample>.embl`: GenBank and EMBL files
- `<sample>.faa`, `<sample>.ffn`, `<sample>.fna`: protein, gene and contig sequences
- `<sample>.tsv`: feature table
- `<sample>.inference.tsv`: the evidence behind each annotation
- `<sample>.hypotheticals.tsv`, `<sample>.hypotheticals.faa`: hypothetical proteins
- `<sample>.json`: everything in one machine-readable file
- `<sample>.txt`: annotation summary
- `<sample>.png`, `<sample>.svg`: circular genome plot

Resistance genes identified by AMRFinderPlus are named in the annotation
files. There is no separate AMRFinderPlus report.

## MultiQC

`multiqc/`

- `multiqc_report.html`: one report combining FastQC, fastp, QUAST, CheckM2,
  Prokka and Bakta results for all samples
- `multiqc_report_data/`: the parsed data behind the report

## Pipeline information

`pipeline_info/`

- `execution_report.html`, `execution_timeline.html`, `execution_trace.txt`:
  Nextflow reports on run time and resource use
