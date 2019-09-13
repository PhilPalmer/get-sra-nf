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

if (params.experiment) {
  Channel
  .fromPath(params.experiment)
  .ifEmpty { exit 1, "Experiment CSV file not found: ${params.experiment}" }
  .splitCsv(skip: 1)
  .map { sraID, condition, replicate -> [ sraID.trim(), condition.trim(), replicate.trim() ] }
  .set { experiment }
}

/*--------------------------------------------------
  Get SRA IDs
---------------------------------------------------*/

process getSRAIDs {
  tag "$id,$condition,$replicate"
  publishDir "${params.outdir}/tmp", mode: 'copy'

  cpus 1

  input:
  set val(id), val(condition), val(replicate) from experiment

  output:
  file "sra_${condition}_${replicate}.txt" into ( sraIDs, sraIDs_to_combine )

  script:
  """
  esearch -db sra -query $id  | efetch --format runinfo | grep SRR | cut -d ',' -f 1 > sra_${condition}_${replicate}.txt
  sed -e 's/\$/,$condition,$replicate/' -i sra_${condition}_${replicate}.txt
  """
}

sraIDs.splitCsv()
      .set { singleSRAId }

/*--------------------------------------------------
  Download FastQ files
---------------------------------------------------*/

process fastqDump {
    tag "$id,$condition,$replicate"
    publishDir "${params.outdir}/reads", mode: 'copy'

    cpus threads

    input:
    set val(id), val(condition), val(replicate) from singleSRAId

    output:
    set val(id), file('*.fastq.gz') into read_files

    script:
    """
    parallel-fastq-dump --sra-id $id --threads ${task.cpus} --gzip
    """ 
}

/*--------------------------------------------------
  Get annotations for all SRAIDs
---------------------------------------------------*/

process getSRAIDsAnnotations {
  publishDir "${params.outdir}/annotation", mode: 'copy'

  cpus 1

  input:
  file (sraIDs) from sraIDs_to_combine.collect()

  output:
  file 'annotation.csv' into annotations

  script:
  """
  echo 'sample_id,treatment,biological_replicate' > annotation.csv
  cat $sraIDs >> annotation.csv
  """
}