//
// Check input samplesheet and get read and assembly channels
//

workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:
    inputs = channel.fromPath(samplesheet, checkIfExists: true)
        .splitCsv(header: true, strip: true)
        .map { row -> create_input_channel(row) }
        .groupTuple()
        .map { meta, types, files ->
            if (types.size() > 1) {
                error("Samplesheet: sample '${meta.id}' appears more than once")
            }
            [meta, types[0], files[0]]
        }
        .branch { meta, type, files ->
            reads: type == 'reads'
                return [meta, files]
            assemblies: type == 'assembly'
                return [meta, files[0]]
        }

    emit:
    reads      = inputs.reads      // channel: [ val(meta), [ fastq_1, fastq_2 ] ]
    assemblies = inputs.assemblies // channel: [ val(meta), fasta ]
}

// Function to get list of [ meta, type, [ files ] ] where type is 'reads' or 'assembly'
def create_input_channel(row) {
    if (!row.sample) {
        error("Samplesheet: column 'sample' is missing or empty in row: ${row}")
    }
    if (row.sample.contains(' ')) {
        error("Samplesheet: sample name '${row.sample}' must not contain spaces")
    }

    def meta = [id: row.sample]
    def has_reads = row.fastq_1 || row.fastq_2

    if (row.fasta && has_reads) {
        error("Samplesheet: sample '${row.sample}' has both reads and an assembly; provide either 'fastq_1' and 'fastq_2', or 'fasta'")
    }
    if (row.fasta) {
        return [meta, 'assembly', [file(row.fasta, checkIfExists: true)]]
    }
    if (!row.fastq_1 || !row.fastq_2) {
        error("Samplesheet: sample '${row.sample}' needs either both 'fastq_1' and 'fastq_2', or 'fasta'")
    }

    def fastq_1 = file(row.fastq_1, checkIfExists: true)
    def fastq_2 = file(row.fastq_2, checkIfExists: true)

    return [meta, 'reads', [fastq_1, fastq_2]]
}
