process CHECKM2 {
    tag "${meta.id}"
    label 'process_high'

    conda 'bioconda::checkm2=1.1.0 conda-forge::keras=3.9.0 conda-forge::numpy=1.26.4 conda-forge::pandas=2.2.3 conda-forge::python=3.12.9 conda-forge::scikit-learn=1.6.1 conda-forge::scipy=1.15.2 conda-forge::tensorflow=2.17.0'
    container "${workflow.containerEngine in ['singularity', 'apptainer']
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/0a/0af812c983aeffc99c0fca9ed2c910816b2ddb9a9d0dcad7b87dab0c9c08a16f/data'
        : 'community.wave.seqera.io/library/checkm2:1.1.0--60f287bc25d7a10d'}"

    input:
    tuple val(meta), path(assembly)
    path db

    output:
    tuple val(meta), path("${meta.id}"), emit: results
    tuple val(meta), path("${meta.id}/quality_report.tsv"), emit: report

    script:
    def args = task.ext.args ?: ''
    def prefix = "${meta.id}"
    """
    # Name the genome after the sample so the report uses the sample name
    mkdir input
    ln -s \$PWD/${assembly} input/${prefix}.fna

    # Accept either the DIAMOND database file or a directory containing it
    db_path=\$PWD/${db}
    if [ -d "\$db_path" ]; then
        db_path=\$(find -L "\$db_path" -name "*.dmnd" | head -n 1)
    fi

    # Passing the database via CHECKM2DB instead of --database_path skips
    # CheckM2's hardcoded checksum check
    export CHECKM2DB=\$db_path

    checkm2 \\
        predict \\
        --input input \\
        --extension fna \\
        --output-directory ${prefix} \\
        --threads ${task.cpus} \\
        ${args}
    """
}
