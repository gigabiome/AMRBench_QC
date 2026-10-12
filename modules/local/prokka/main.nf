process PROKKA {
    tag "${meta.id}"
    label 'process_medium'

    conda 'bioconda::prokka=1.15.6'
    container 'quay.io/biocontainers/prokka:1.15.6--pl5321hdfd78af_0'

    input:
    tuple val(meta), path(assembly)

    output:
    tuple val(meta), path("${meta.id}"), emit: annotation
    tuple val(meta), path("${meta.id}/*.gff"), emit: gff
    tuple val(meta), path("${meta.id}/*.faa"), emit: faa
    tuple val(meta), path("${meta.id}/*.txt"), emit: txt

    script:
    def args = task.ext.args ?: ''
    def prefix = "${meta.id}"
    // Prokka cannot read gzipped FASTA
    def is_compressed = assembly.name.endsWith('.gz')
    def fasta = is_compressed ? "${prefix}.input.fasta" : "${assembly}"
    def decompress = is_compressed ? "gzip -cd ${assembly} > ${fasta}" : ''
    """
    ${decompress}

    prokka \\
        --outdir ${prefix} \\
        --prefix ${prefix} \\
        --kingdom Bacteria \\
        --cpus ${task.cpus} \\
        ${args} \\
        ${fasta}
    """
}
