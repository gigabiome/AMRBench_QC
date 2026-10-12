process PLASMIDFINDER {
    tag "${meta.id}"
    label 'process_low'

    // The PlasmidFinder database ships inside the container and conda package
    conda 'bioconda::plasmidfinder=2.1.6'
    container 'quay.io/biocontainers/plasmidfinder:2.1.6--py310hdfd78af_1'

    input:
    tuple val(meta), path(assembly)

    output:
    tuple val(meta), path("*.json"), emit: json
    tuple val(meta), path("*.txt"), emit: txt
    tuple val(meta), path("*.tsv"), emit: tsv
    tuple val(meta), path("*-hit_in_genome_seq.fsa"), emit: genome_seq
    tuple val(meta), path("*-plasmid_seqs.fsa"), emit: plasmid_seq

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    plasmidfinder.py \\
        ${args} \\
        -i ${assembly} \\
        -o ./ \\
        -x

    # Rename hard-coded outputs with prefix to avoid name collisions
    mv data.json ${prefix}.json
    mv results.txt ${prefix}.txt
    mv results_tab.tsv ${prefix}.tsv
    mv Hit_in_genome_seq.fsa ${prefix}-hit_in_genome_seq.fsa
    mv Plasmid_seqs.fsa ${prefix}-plasmid_seqs.fsa
    """
}
