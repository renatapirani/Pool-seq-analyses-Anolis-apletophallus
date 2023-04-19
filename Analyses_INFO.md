# Pool-Seq preparation of _Anolis apletophallus_ dewlap data (Solid and Bicolor morph)

## 2 Main Files: 

* FOLDER: Bicolor_morph (50 ind, bicolor dewlap)

files names: WOM_B01_2-1259687_S1_L001_R1_001.fastq.gz, WOM_B01_2-1259687_S1_L001_R2_001.fastq.gz


* FOLDER: Solid_morph (50 ind, solid dewlap)
	
files names: WOM_S02_2-1259687_S2_L001_R1_001.fastq.gz, WOM_S02_2-1259687_S2_L001_R2_001.fastq.gz
		
		
* Pipeline - Anolis poolseq

Following the paper Micheletti & Narum (2018)

GitHub = https://github.com/StevenMicheletti/poolparty
Citation: "Micheletti SJ and SR Narum. 2018. Utility of pooled sequencing for association 
mapping in nonmodel organisms. Molecular Ecology Resources 10.1111/1755-0998.12784"

The pipeline was performed with 30 threads on the Smithsonian Institution High Performance Computing Cluster 
(citation: Smithsonian Institution High Performance Computing Cluster. Smithsonian Institution)

All the paremeters used here are described in the manuscript. 


# Step 1 - Genome preparation

WORK FOLDER HYDRA: /scratch/genomics/piranir/poolparty
											

* make a folder with all the fastq.gz files: S02_2-1259687_S2_L001_R1_001.fastq.gz, S02_2-1259687_S2_L001_R2_001.fastq.gz (SOLID DEWLAP)
											 B01_2-1259687_S1_L001_R1_001.fastq.gz, B01_2-1259687_S1_L001_R2_001.fastq.gz (BICOLOR DEWLAP)
											 
	** I changed the names of the files (removed the WOM_ from the beginning of the names) **
											 
* comparing the 2 morph -> the solid and bicolor dewlap   	
* use a reference genome --> AnoAple_1.1.fasta (Pirani et al. 2023)
* Preparing the genome before using it
* For this use the script -> prep_genome.sh
* Help: http://broadinstitute.github.io/picard/command-line-overview.html -> CreateSequenceDictionary

* 1 JOB: /scratch/genomics/piranir/poolparty/example/prep_bwa.job

	+ **module**: ```module load bioinformatics/bwa/0.7.17```
	+ **module**: ```bwa index -a bwtsw AnoAple_1.1.fasta```
 
                                                                                                                       
* 2 JOB: prep_samtools.job

	+ **module**: ```module load bioinformatics/samtools```
  	+ **module**: ```samtools faidx AnoAple_1.1.fasta```                                                                                                                                             


* 3 JOB: prep_java.job
	
	+ **module**: ```module load bioinformatics/picard-tools/2.20.6```
	+ **module**: ```java -jar picard.jar CreateSequenceDictionary \```
	+ **module**: ```R=AnoAple_1.1.fasta \```
	+ **module**: ```O=AnoAple_1.1.fasta.dict```  



# Step 2: Alignment 
												
	
* open the "pp_align.config" file and make the changes for this data 
	-> I am configuring it based on the results from the sequence company
	
* create the folder -> dewlapSB
* copy the folder popoolation2_1201 from /home/ariasc/programs/popoolation to your folder (do this for the first time)
* download samblaster from "git clone git://github.com/GregoryFaust/samblaster.git" (do this for the first time)
* HELP: install conda -  https://confluence.si.edu/display/HPC/Conda+tutorial (install R packages and everything else) (do this for the first time)

	 
* File samplelist.txt = the file with the fastq files divided by morph (solid or bicolor).  

	* 1 JOB: pp_align.job

  		+ **module**: ```module load bioinformatics/bcftools/1.9```
  		+ **module**: ```module load bioinformatics/fastqc/0.11.8```
  		+ **module**: ```module load bioinformatics/bwa/0.7.17```
  		+ **module**: ```module load bioinformatics/samtools```
  		+ **module**: ```module load ~/modulefiles/miniconda```
  		+ **module**: ```source activate tidyverse``` 

		+ **command**: ```./PPalign pp_align.config```  

--------------

After finishing running.  

* to check for the ERRORS and ALERTS

- grep "ALERT" pp_align.log
- grep "ERROR" pp_align.log
- grep "duplicates" pp_align.log


* checking for the reads quality
- grep "Low quality" pp_align.log

* check for contamination, should be nothing
- grep "Contaminant" pp_align.log (no contamination - GOOD)

* To call for SNPs
- grep "SNPs" pp_align.log

* To call for indels
- grep "indel" pp_align.log

* check the .log file in the end of the run
* The results are presented at the Table 2 of the manuscript

## Total Results
>> grep "ALERT" pp_aling.log
ALERT: See dewlapSB_files_for_pops.txt for population merge order
ALERT: 60429504 SNPs total SNPS called without filters
ALERT: 7145492 SNPs removed due to QUAL < 15 and total DP < 10 
ALERT: Additional 2653066 SNPs removed due to global MAF < 0.05 
ALERT: 50630946 total SNPs retained after SNP calling
ALERT: Of the remaining SNPs, there are 44531648 SNPs and 6099298 INDels
ALERT: Variant calling and filtering done at Sun Mar 27 01:37:57 EDT 2022 
ALERT: mpileups are being created at  Sun Mar 27 01:37:57 EDT 2022
ALERT: Mpileups created at Sun Mar 27 04:01:44 EDT 2022
ALERT: Identifying indel regions and creating sync format at Sun Mar 27 04:01:44 EDT 2022
ALERT: Done identifying indel regions and creating sync format at Sun Mar 27 04:19:37 EDT 2022
ALERT: With an indel window of 15 bp you lost 11818072 SNPs or 24 % 
 "R ALERT: Determining .sync stats for pop_1"
[1] "R ALERT: Performing corrections on .sync file"
[1] "R ALERT: 9940 SNPs in pop_1 had 3 or more alleles. These will be blacklisted."
[1] "R ALERT: R is writing files to disk"
[1] "R ALERT: Determining .sync stats for pop_2"
[1] "R ALERT: Performing corrections on .sync file"
[1] "R ALERT: 13961 SNPs in pop_2 had 3 or more alleles. These will be blacklisted."
[1] "R ALERT: R is writing files to disk"
ALERT: Rscript standardization done at Sun Mar 27 06:35:04 EDT 2022 
ALERT: Normalized sync file order is: 
ALERT: With an indel window of 15 bp you lost 11818072 SNPs or 24 %
ALERT: Alignment and data creation step finished at Sun Mar 27 06:41:53 EDT 2022 
ALERT: Creating allele frequency tables in R
ALERT: Rscript called to calculate allele frequencies at Sun Mar 27 06:41:53 EDT 2022 
[1] "R ALERT: Formatting file and calculating summary stats"
[1] "R ALERT: Calculating depth of coverage at each position"
[1] "R ALERT: Noting potential paralogs (>3 alleles per position)"
[1] "R ALERT: Calculating Allele Frequencies"
[1] "R ALERT: Determining Positions that fail MAF"
[1] "R ALERT: 25983 SNPS (0.07%) do not pass additional population MAF threshold of 0.05 and have been noted"
[1] "R ALERT: Writing output files"
ALERT: Frequency file dewlapSB_full.fz and its counterparts created at Sun Mar 27 06:56:32 EDT 2022 
[1] "R ALERT: Formatting file and calculating summary stats"
[1] "R ALERT: Noting potential paralogs (>3 alleles per position)"
[1] "R ALERT: Calculating Allele Frequencies"
[1] "R ALERT: Determining Positions that fail MAF"
[1] "R ALERT: 908246 SNPS (2.37%) do not pass additional population MAF threshold of 0.05 and have been noted"
[1] "R ALERT: Writing output files"
ALERT: Frequency file dewlapSB_norm_full.fz and its counterparts created at Sun Mar 27 07:08:13 EDT 2022 
ALERT: PPalign completed at Sun Mar 27 07:08:13 EDT 2022 


## Results pop_1.bam
(base) -bash-4.2$ samtools flagstat pop_1.bam -@ 5                                                                
533607347 + 0 in total (QC-passed reads + QC-failed reads)                                                          
2683784 + 0 secondary                                                                                               
0 + 0 supplementary                                                                                                 
0 + 0 duplicates                                                                                                    
533607347 + 0 mapped (100.00% : N/A)                                                                                
530923563 + 0 paired in sequencing                                                                                  
265519237 + 0 read1                                                                                                 
265404326 + 0 read2                                                                                                 
530923563 + 0 properly paired (100.00% : N/A)                                                                       
530923563 + 0 with itself and mate mapped                                                                           
0 + 0 singletons (0.00% : N/A)                                                                                      
0 + 0 with mate mapped to a different chr                                                                           
0 + 0 with mate mapped to a different chr (mapQ>=5)


## Results pop_2.bam
(base) -bash-4.2$ samtools flagstat pop_2.bam -@ 5                                                                
687661349 + 0 in total (QC-passed reads + QC-failed reads)                                                          
3493537 + 0 secondary                                                                                               
0 + 0 supplementary                                                                                                 
0 + 0 duplicates                                                                                                    
687661349 + 0 mapped (100.00% : N/A)                                                                                
684167812 + 0 paired in sequencing                                                                                  
342151768 + 0 read1                                                                                                 
342016044 + 0 read2                                                                                                 
684167812 + 0 properly paired (100.00% : N/A)                                                                       
684167812 + 0 with itself and mate mapped                                                                           
0 + 0 singletons (0.00% : N/A)                                                                                      
0 + 0 with mate mapped to a different chr                                                                           
0 + 0 with mate mapped to a different chr (mapQ>=5)



# Step 3: Stats

* Folder: /scratch/genomics/piranir/dewlapSB
* Configure the config file and change the parameters
	* Job file: java.job
                                                                                                                                      
  		+ **command**: ```./PPstats pp_stats.config ```  
  		 

#### Results:
(base) -bash-4.2$ cat PP_stats_summary.txt                                                                                           
Full genome length is 2423059081 bp                                                                                                   
Anchored genome length is 0 bp                                                                                                       
Scaffold length is 2423059081 bp                                                                                                     
Proportion of assembly that is anchored is 0.00000                                                                                   
There are 0 chromosomes                                                                                                               
There are 2 populations in the mpileup                                                                                               
2253390802 bp covered sufficiently by all libraries                                                                                   
0.92998  of genome covered sufficiently by all libraries

Results Figure: PP_stats_prop_cov.pdf


# Step 4: Analyze

* Open the pp_analyze.config file and make some changes:

PREFIX=dewlapSB_analyze                                                                                                               
COVFILE=/scratch/genomics/piranir/NEWpoolparty/example/dewlapSB/filters/dewlapSB_coverage.txt                                         
SYNC=/scratch/genomics/piranir/NEWpoolparty/example/dewlapSB/dewlapSB.sync                                                           
FZFILE=/scratch/genomics/piranir/NEWpoolparty/example/dewlapSB/dewlapSB.fz                                                           
BLACKLIST=/scratch/genomics/piranir/NEWpoolparty/example/dewlapSB/filters/dewlapSB_poly_all.txt
OUTDIR=/scratch/genomics/piranir/NEWpoolparty/example/PPanalyzes

                                                                                                                                
* Folder: /scratch/genomics/piranir/NEWpoolparty/example/dewlapSB
	* Job file: pp_analyze.job

		+ **module**: ```load bioinformatics/bcftools/1.9```
		+ **module**: ```load bioinformatics/fastqc/0.11.8```
		+ **module**: ```load bioinformatics/bwa/0.7.17```
		+ **module**: ```load bioinformatics/samtools```
  		+ **module**: ```load ~/modulefiles/miniconda``` 
  		+ **module**: ```source activate tidyverse``` 
                                                                                                                                     
  		+ **command**: ```./PPanalyze pp_analyze.config```  
                                                                 
#### Some of the results

> awk '$4 > .60' dewlapSB_analyze.fst | wc -l  ### check the fst values
Result: 23771 SNPs had very high Fst (>0.60)

> awk '$4 < .05' dewlapSB_analyze.fet | wc -l  ### check the fet values
Result:  7166521 SNPs had very high Fet (>0.05)

* We used Manhatan plot R scripts to plot the final results


## STEP 5: preparing the files for R


* For this step we used the github Manhattan_plots (https://github.com/Gammerdinger/Manhattan_plots)																

* Command line to export the genome to R 

	+ **command**: ```perl /home/piranir/Manhattan_plots/Running_chrom.pl --input_file=AnoAple_1.1.fasta.fai --output_file=anolis_poolseq_chrom_size.txt```

* Command line to export the Fst file to R

	+ **command**: ```perl /home/piranir/Manhattan_plots/Genome_R_script.pl --input_file=p1_p2_fst.igv --output_file=Anolis.fst.R_ready --chrom_size_file=anolis_poolseq_chrom_size.txt```

* Command line to export the Fisher file to R

	+ **command**: ```perl /home/piranir/Manhattan_plots/Genome_R_script.pl --input_file=p1_p2-fet.igv --output_file=Anolis.fet.R_ready --chrom_size_file=anolis_poolseq_chrom_size.txt```


-> after we are going to work on R: script Poolseq-results.r


## R files and explanation

* Download: we are going to use these files to check the right position of the scaffolds for the Geneious program. 

* p1_p2.fst = this file contain the right position of the scaffolds and the fst values for each position 

* p1_p2.fet = this file contain the right position of the scaffolds and the fet values for each position

* Anolis.fet.R_ready = input files for R but to create this file we need to put all the scaffolds at the same line, which changes the right position 

* Anolis.fet.R_ready = input files for R but to create this file we need to put all the scaffolds at the same line, which changes the right position 


Done.







