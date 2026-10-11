process QUAST {
    tag "${meta.id}"
    label 'process_low'

    conda 'bioconda::quast=5.3.0'
    container 'quay.io/biocontainers/quast:5.3.0--py312pl5321hdcc493e_1'

    input:
    tuple val(meta), path(assembly)

    output:
    tuple val(meta), path("${meta.id}"), emit: report

    script:
    def args = task.ext.args ?: ''
    def prefix = "${meta.id}"
    """
    quast.py \\
        --output-dir ${prefix} \\
        --threads ${task.cpus} \\
        ${args} \\
        ${assembly}
    """
}
