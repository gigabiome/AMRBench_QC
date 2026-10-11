/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { INPUT_CHECK } from '../subworkflows/local/input_check'

include { FASTQC      } from '../modules/local/fastqc/main'
include { FASTP       } from '../modules/local/fastp/main'
include { UNICYCLER   } from '../modules/local/unicycler/main'
include { QUAST       } from '../modules/local/quast/main'
include { PROKKA      } from '../modules/local/prokka/main'
include { MULTIQC     } from '../modules/local/multiqc/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow AMRBENCH_QC {
    main:
    if (!params.input) {
        error("Please provide a samplesheet, e.g. --input samplesheet.csv")
    }

    //
    // SUBWORKFLOW: Read in samplesheet, validate and stage input files
    //
    INPUT_CHECK(params.input)

    //
    // MODULE: Raw read QC
    //
    FASTQC(INPUT_CHECK.out.reads)

    //
    // MODULE: Adapter and quality trimming
    //
    FASTP(INPUT_CHECK.out.reads)

    //
    // MODULE: Genome assembly
    //
    UNICYCLER(FASTP.out.reads)

    //
    // MODULE: Assembly QC
    //
    QUAST(UNICYCLER.out.assembly)

    //
    // MODULE: Gene prediction and annotation
    //
    PROKKA(UNICYCLER.out.assembly)

    //
    // MODULE: MultiQC
    //
    multiqc_files = FASTQC.out.zip
        .mix(FASTP.out.json, QUAST.out.report, PROKKA.out.txt)
        .map { _meta, report -> report }
        .collect()
    multiqc_config = file("${projectDir}/assets/multiqc_config.yml", checkIfExists: true)

    MULTIQC(multiqc_files, multiqc_config)

    emit:
    assembly       = UNICYCLER.out.assembly // channel: [ val(meta), fasta ]
    annotation     = PROKKA.out.annotation  // channel: [ val(meta), dir ]
    multiqc_report = MULTIQC.out.report     // channel: multiqc_report.html
}
