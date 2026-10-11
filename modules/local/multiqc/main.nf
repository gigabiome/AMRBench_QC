process MULTIQC {
    label 'process_low'

    conda 'bioconda::multiqc=1.35'
    container 'quay.io/biocontainers/multiqc:1.35--pyhdfd78af_2'

    input:
    path multiqc_files, stageAs: 'input/*'
    path multiqc_config

    output:
    path "multiqc_report.html", emit: report
    path "multiqc_data", emit: data

    script:
    def args = task.ext.args ?: ''
    """
    multiqc \\
        --config ${multiqc_config} \\
        ${args} \\
        input
    """
}
