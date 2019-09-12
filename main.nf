#!/usr/bin/env nextflow
/*
========================================================================================
                         PhilPalmer/get-sra-nf
========================================================================================
 PhilPalmer/get-sra-nf Download FastQ files from SRA by project or SRA ID
 #### Homepage / Documentation
 https://github.com/PhilPalmer/get-sra-nf
 Heavily inspired by https://github.com/lifebit-ai/kallisto-sra
----------------------------------------------------------------------------------------
*/

int threads = Runtime.getRuntime().availableProcessors()

accessionID = params.accession

if (params.experiment) {
  Channel
  .fromPath(params.experiment)
  .ifEmpty { exit 1, "Experiment CSV file not found: ${params.experiment}" }
  .splitCsv(skip: 1)
  .map { sraID, condition -> sraID }
  .set { singleSRAId }
}

/*--------------------------------------------------
  If user has specified accession get SRA IDs
---------------------------------------------------*/

if (params.accession) {
  process getSRAIDs {
    tag "$id"

    cpus 1

    input:
    val id from accessionID

    output:
    file 'sra.txt' into sraIDs

    script:
    """
    esearch -db sra -query $id  | efetch --format runinfo | grep SRR | cut -d ',' -f 1 > sra.txt
    """
  }

  sraIDs.splitText().map { it -> it.trim() }.set { singleSRAId }
}

/*--------------------------------------------------
  Download FastQ files
---------------------------------------------------*/

process fastqDump {

    tag "$id"

    publishDir params.outdir, mode: 'copy'

    cpus threads

    input:
    val id from singleSRAId

    output:
    set val(id), file('*.fastq.gz') into read_files

    script:
    """
    parallel-fastq-dump --sra-id $id --threads ${task.cpus} --gzip
    """ 
}