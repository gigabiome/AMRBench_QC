/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { INPUT_CHECK        } from '../subworkflows/local/input_check'

include { FASTQC             } from '../modules/local/fastqc/main'
include { FASTP              } from '../modules/local/fastp/main'
include { UNICYCLER          } from '../modules/local/unicycler/main'
include { GUNZIP             } from '../modules/local/gunzip/main'
include { QUAST              } from '../modules/local/quast/main'
include { CHECKM2_DBDOWNLOAD } from '../modules/local/checkm2_dbdownload/main'
include { CHECKM2            } from '../modules/local/checkm2/main'
include { PLASMIDFINDER      } from '../modules/local/plasmidfinder/main'
include { PROKKA             } from '../modules/local/prokka/main'
include { BAKTA_DBDOWNLOAD   } from '../modules/local/bakta_dbdownload/main'
include { BAKTA              } from '../modules/local/bakta/main'
include { MULTIQC            } from '../modules/local/multiqc/main'

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
    if (!(params.bakta_db_type in ['full', 'light'])) {
        error("--bakta_db_type must be 'full' or 'light', not '${params.bakta_db_type}'")
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
    // MODULE: Decompress any gzipped assemblies supplied in the samplesheet
    //
    supplied = INPUT_CHECK.out.assemblies.branch { _meta, fasta ->
        compressed: fasta.name.endsWith('.gz')
        plain: true
    }
    GUNZIP(supplied.compressed)

    //
    // Assemblies made here plus any supplied directly in the samplesheet.
    // Every step below runs on both.
    //
    assemblies = UNICYCLER.out.assembly.mix(supplied.plain, GUNZIP.out.fasta)

    //
    // MODULE: Assembly QC
    //
    QUAST(assemblies)

    //
    // MODULE: Completeness and contamination
    //
    if (params.checkm2_db) {
        checkm2_db = channel.value(file(params.checkm2_db, checkIfExists: true))
    } else {
        CHECKM2_DBDOWNLOAD()
        checkm2_db = CHECKM2_DBDOWNLOAD.out.db.collect()
    }
    CHECKM2(assemblies, checkm2_db)

    //
    // MODULE: Plasmid replicon typing
    //
    PLASMIDFINDER(assemblies)

    //
    // MODULE: Gene prediction and annotation with Prokka (optional)
    //
    prokka_txt = channel.empty()
    if (!params.skip_prokka) {
        PROKKA(assemblies)
        prokka_txt = PROKKA.out.txt
    }

    //
    // MODULE: Gene prediction and annotation with Bakta
    //
    if (params.bakta_db) {
        bakta_db = channel.value(file(params.bakta_db, checkIfExists: true))
    } else {
        BAKTA_DBDOWNLOAD(params.bakta_db_type)
        bakta_db = BAKTA_DBDOWNLOAD.out.db.collect()
    }
    BAKTA(assemblies, bakta_db)

    //
    // MODULE: MultiQC
    //
    multiqc_files = FASTQC.out.zip
        .mix(
            FASTP.out.json,
            QUAST.out.report,
            CHECKM2.out.report,
            prokka_txt,
            BAKTA.out.txt,
        )
        .map { _meta, report -> report }
        .collect()
    multiqc_config = file("${projectDir}/assets/multiqc_config.yml", checkIfExists: true)

    MULTIQC(multiqc_files, multiqc_config)

    emit:
    assembly       = assemblies         // channel: [ val(meta), fasta ]
    multiqc_report = MULTIQC.out.report // channel: multiqc_report.html
}
