process CHECKM2_DBDOWNLOAD {
    label 'process_low'

    conda 'conda-forge::aria2=1.37.0'
    container "${workflow.containerEngine in ['singularity', 'apptainer']
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/95/95c0d3d867f5bc805b926b08ee761a993b24062739743eb82cc56363e0f7817d/data'
        : 'community.wave.seqera.io/library/aria2:1.37.0--3a9ec328469995dd'}"

    output:
    path "checkm2_db.dmnd", emit: db

    script:
    def args = task.ext.args ?: ''
    """
    # CheckM2's own downloader is broken under Singularity/Apptainer
    # (https://github.com/chklovski/CheckM2/issues/73), so fetch it from Zenodo
    aria2c \\
        --user-agent="Wget/1.21.4" \\
        ${args} \\
        https://zenodo.org/records/14897628/files/checkm2_database.tar.gz

    tar -xzf checkm2_database.tar.gz
    mv \$(find . -name "*.dmnd" | head -n 1) checkm2_db.dmnd
    rm -f checkm2_database.tar.gz
    """
}
