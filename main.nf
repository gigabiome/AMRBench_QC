#!/usr/bin/env nextflow

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    gigabiome/AMRBench_QC
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Read QC, assembly and gene prediction for bacterial genomes
    Github : https://github.com/gigabiome/AMRBench_QC
----------------------------------------------------------------------------------
*/

include { AMRBENCH_QC } from './workflows/amrbench_qc'

workflow {
    AMRBENCH_QC()
}
