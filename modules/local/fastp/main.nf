process FASTP {
    tag "${meta.id}"
    label 'process_medium'

    conda 'bioconda::fastp=1.4.0'
    container 'quay.io/biocontainers/fastp:1.4.0--h43da1c4_0'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.fastp.fastq.gz"), emit: reads
    tuple val(meta), path("*.fastp.json"), emit: json
    tuple val(meta), path("*.fastp.html"), emit: html
    tuple val(meta), path("*.fastp.log"), emit: log

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    fastp \\
        --in1 ${reads[0]} \\
        --in2 ${reads[1]} \\
        --out1 ${prefix}_1.fastp.fastq.gz \\
        --out2 ${prefix}_2.fastp.fastq.gz \\
        --json ${prefix}.fastp.json \\
        --html ${prefix}.fastp.html \\
        --detect_adapter_for_pe \\
        --thread ${task.cpus} \\
        ${args} \\
        2> >(tee ${prefix}.fastp.log >&2)
    """
}
