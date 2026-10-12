process BAKTA_DBDOWNLOAD {
    label 'process_low'

    conda 'bioconda::bakta=1.12.0 bioconda::diamond=2.2.0'
    container "${workflow.containerEngine in ['singularity', 'apptainer']
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/50/50b75335f6394ae83fd05f364db27ee2eb75f4170e3525bb2aea47ad717a9e64/data'
        : 'community.wave.seqera.io/library/bakta_diamond:7830b94718da4f96'}"

    input:
    val db_type // 'full' or 'light'

    output:
    path "bakta_db_${db_type}", emit: db

    script:
    def args = task.ext.args ?: ''
    """
    # Fake home due to fontconfig 'no writeable cache directory' issue
    mkdir nxf_home
    export HOME=\$PWD/nxf_home

    # Downloads the Bakta database and sets up its bundled AMRFinderPlus database
    bakta_db \\
        download \\
        --output download \\
        --type ${db_type} \\
        ${args}

    mv download/db* bakta_db_${db_type}
    """
}
