process UNICYCLER {
    tag "${meta.id}"
    label 'process_high'

    conda 'bioconda::unicycler=0.5.1'
    container 'quay.io/biocontainers/unicycler:0.5.1--py312hdcc493e_5'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.fasta"), emit: assembly
    tuple val(meta), path("*.gfa"), emit: gfa
    tuple val(meta), path("*.unicycler.log"), emit: log

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    unicycler \\
        --short1 ${reads[0]} \\
        --short2 ${reads[1]} \\
        --out unicycler_out \\
        --threads ${task.cpus} \\
        ${args}

    mv unicycler_out/assembly.fasta ${prefix}.fasta
    mv unicycler_out/assembly.gfa ${prefix}.gfa
    mv unicycler_out/unicycler.log ${prefix}.unicycler.log
    """
}
