//
// Check input samplesheet and get read channels
//

workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:
    reads = channel.fromPath(samplesheet, checkIfExists: true)
        .splitCsv(header: true, strip: true)
        .map { row -> create_fastq_channel(row) }
        .groupTuple()
        .map { meta, fastqs ->
            if (fastqs.size() > 1) {
                error("Samplesheet: sample '${meta.id}' appears more than once")
            }
            [meta, fastqs[0]]
        }

    emit:
    reads // channel: [ val(meta), [ fastq_1, fastq_2 ] ]
}

// Function to get list of [ meta, [ fastq_1, fastq_2 ] ]
def create_fastq_channel(row) {
    ['sample', 'fastq_1', 'fastq_2'].each { column ->
        if (!row[column]) {
            error("Samplesheet: column '${column}' is missing or empty in row: ${row}")
        }
    }
    if (row.sample.contains(' ')) {
        error("Samplesheet: sample name '${row.sample}' must not contain spaces")
    }

    def meta = [id: row.sample]
    def fastq_1 = file(row.fastq_1, checkIfExists: true)
    def fastq_2 = file(row.fastq_2, checkIfExists: true)

    return [meta, [fastq_1, fastq_2]]
}
