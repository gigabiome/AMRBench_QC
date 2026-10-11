process FASTQC {
    tag "${meta.id}"
    label 'process_low'

    conda 'bioconda::fastqc=0.13.0'
    container 'quay.io/biocontainers/fastqc:0.13.0--hdfd78af_0'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.html"), emit: html
    tuple val(meta), path("*.zip"), emit: zip

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    # Name the reads after the sample so reports are unique per sample
    if [ ! -e ${prefix}_1.fastq.gz ]; then ln -s ${reads[0]} ${prefix}_1.fastq.gz; fi
    if [ ! -e ${prefix}_2.fastq.gz ]; then ln -s ${reads[1]} ${prefix}_2.fastq.gz; fi

    fastqc \\
        ${args} \\
        --threads ${task.cpus} \\
        ${prefix}_1.fastq.gz \\
        ${prefix}_2.fastq.gz
    """
}
