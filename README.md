# get-sra-nf

A Nextflow pipeline for fetching samples directly from SRA

## Quick start 

Make sure you have all the required dependencies listed in the last section.

Install the Nextflow runtime by running the following command:

    $ curl -fsSL get.nextflow.io | bash


When done, you can launch the pipeline execution by entering the command shown below:

    $ nextflow run PhilPalmer/get-sra-id
    

By default the pipeline is executed against the provided example dataset. 
Check the *Pipeline parameters*  section below to see how enter your data on the program 
command line.     
    


## Pipeline parameters

#### `--accession` 
   
* Specifies identifier of a sample or a project accession number found in SRA database.
* Accession of a single sample can also be provided
* Accession numbers must be found in SRA DB, like SRR, SRX, PRJ, ...
* Involved in the task: fetch_sra and fastq-download.

Example: 

    $ nextflow run PhilPalmer/get-sra-id --accession 'XXX'

This will connect to SRA DB and fetch all information related to the sample and/or project, which will be used to download automatically all sample fastq files in parallel.

The accession number may be specified as below for a single sample from SRA:

    $ nextflow run PhilPalmer/get-sra-id --accession 'SRR925734'    


Or be specified as a project ID accession:

    $ nextflow run PhilPalmer/get-sra-id --accession 'PRJNA210428'

OR

#### `--experiment` 
   
* To specify a list of SRA ID's to download. This can be a two column CSV file where the first column will be used to get the SRA ID's

Example: 

    $ nextflow run PhilPalmer/get-sra-id --experiment /path/to/my_experiment_file.csv

This will connect to SRA DB and fetch all information related to the sample and/or project, which will be used to download automatically all sample fastq files in parallel.


#### `--outdir` 
   
* Specifies the folder where the results will be stored for the user.  
* It does not matter if the folder does not exist.
* By default is set to folder: `./results` 

Example: 

    $ nextflow run accession --outdir /home/user/my_results 
  

To lean more about the avaible settings and the configuration file read the 
[Nextflow documentation](http://www.nextflow.io/docs/latest/config.html).
  
  
Dependencies 
------------

 * [Nextflow](http://nextflow.io) (0.24.0 or higher)
 * [Docker](https://docker.com)