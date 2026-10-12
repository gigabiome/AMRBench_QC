process MULTIQC {
    label 'process_low'

    conda 'bioconda::multiqc=1.35'
    container 'quay.io/biocontainers/multiqc:1.35--pyhdfd78af_2'

    input:
    path multiqc_files, stageAs: '?/*'
    path multiqc_config

    output:
    path "multiqc_report.html", emit: report
    path "multiqc_report_data", emit: data

    script:
    def args = task.ext.args ?: ''
    """
    # A report title changes MultiQC's default output names, so fix them here
    multiqc \\
        --force \\
        --filename multiqc_report \\
        --config ${multiqc_config} \\
        ${args} \\
        .
    """
}
