process GUNZIP {
    tag "${meta.id}"
    label 'process_low'

    conda 'conda-forge::gzip'
    container 'quay.io/nf-core/ubuntu:22.04'

    input:
    tuple val(meta), path(archive)

    output:
    tuple val(meta), path("${meta.id}.fasta"), emit: fasta

    script:
    """
    gzip -cd ${archive} > ${meta.id}.fasta
    """
}
