process BAKTA {
    tag "${meta.id}"
    label 'process_high'

    conda 'bioconda::bakta=1.12.0 bioconda::diamond=2.2.0'
    container "${workflow.containerEngine in ['singularity', 'apptainer']
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/50/50b75335f6394ae83fd05f364db27ee2eb75f4170e3525bb2aea47ad717a9e64/data'
        : 'community.wave.seqera.io/library/bakta_diamond:7830b94718da4f96'}"

    input:
    tuple val(meta), path(assembly)
    path db

    output:
    tuple val(meta), path("${meta.id}"), emit: annotation
    tuple val(meta), path("${meta.id}/${meta.id}.gff3"), emit: gff
    tuple val(meta), path("${meta.id}/${meta.id}.faa"), emit: faa
    tuple val(meta), path("${meta.id}/${meta.id}.tsv"), emit: tsv
    tuple val(meta), path("${meta.id}/${meta.id}.txt"), emit: txt

    script:
    def args = task.ext.args ?: ''
    def prefix = "${meta.id}"
    """
    # Fake home due to fontconfig 'no writeable cache directory' issue
    mkdir nxf_home
    export HOME=\$PWD/nxf_home

    bakta \\
        --db ${db} \\
        --output ${prefix} \\
        --prefix ${prefix} \\
        --threads ${task.cpus} \\
        ${args} \\
        ${assembly}
    """
}
