# Pool-Seq preparation of _ANOLIS APLETOPHALLUS_ dewlap data (Solid and Bicolor morph)

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



# Step 1 - Genome preparation

WORK FOLDER HYDRA: /scratch/genomics/piranir/poolparty
											

* make a folder with all the fastq.gz files: S02_2-1259687_S2_L001_R1_001.fastq.gz, S02_2-1259687_S2_L001_R2_001.fastq.gz (SOLID DEWLAP - POP2)
											 B01_2-1259687_S1_L001_R1_001.fastq.gz, B01_2-1259687_S1_L001_R2_001.fastq.gz (BICOLOR DEWLAP - POP1)
											 
	** I changed the names of the files (removed the WOM_ from the beginning of the names) **
											 
* comparing the 2 morph -> the solid and bicolor dewlap.   	
* use a reference genome --> AnoAple_1.1.fasta (Pirani et al. 2023)
* obs: sometimes you need to prepare the genome before using it. 
* For this use the script (prep_genome.sh)
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



# Step 2 : Alignment 
												
	
* open the "pp_align.config" file and make the changes for this data 
	-> I am configuring it based on the results from the sequence company
	
* create the folder -> dewlapSB
* copy the folder popoolation2_1201 from /home/ariasc/programs/popoolation to your folder (do for the first time)
* download samblaster from "git clone git://github.com/GregoryFaust/samblaster.git" (do this for the first time)
* HELP: install conda -  https://confluence.si.edu/display/HPC/Conda+tutorial (install R packages and everything else) (do this for the first time)

	 
* File samplelist.txt = the file with the fastq files divided by population (solid or bicolor).  

	* 1 JOB: pp_align.job

  		+ **module**: ```module load bioinformatics/bcftools/1.9```
  		+ **module**: ```module load bioinformatics/fastqc/0.11.8```
  		+ **module**: ```module load bioinformatics/bwa/0.7.17```
  		+ **module**: ```module load bioinformatics/samtools```
  		+ **module**: ```module load ~/modulefiles/miniconda```
  		+ **module**: ```source activate tidyverse```
  		+ **module**: ```./PPalign pp_align.config```  

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


* RUNNIG FILES:
- Now we are going to run the jobs in a different way 
- check the sites: https://sourceforge.net/p/popoolation2/wiki/Tutorial/
					http://www.htslib.org/doc/samtools-mpileup.html

* Folder: /scratch/genomics/piranir/BAM_files_Anolis/BAM
	* Files: pop_1.bam, pop_2.bam 
	* Job file: samtools.job

  		+ **module**: ```module load bioinformatics/samtools``` 
                                                                                                                                      
  		+ **command**: ```samtools mpileup -B pop_1.bam pop_2.bam > p1_p2.mpileup```  


#### After use Popoolation2

* Folder: /scratch/genomics/piranir/BAM_files_Anolis/BAM
	* Job file: java.job
	
  		+ **module**: ```source /home/ariasc/.bashrc``` 
  		+ **module**: ```conda activate poolp2``` 
                                                                                                                                      
  		+ **command**: ```java -ea -Xmx80g -jar /home/piranir/popoolation2_1201/mpileup2sync.jar --input p1_p2.mpileup --output p1_p2_java.sync --fastq-type sanger --min-qual 10 --threads 30```  
  		


#### Calculate allele frequency differences

* Folder: /scratch/genomics/piranir/BAM_files_Anolis/BAM
	* Job file: allele.job


  		+ **module**: ```source /home/ariasc/.bashrc``` 
  		+ **module**: ```conda activate poolp2```  
                                                                                                                                      
  		+ **command**: ```perl /home/piranir/popoolation2_1201/snp-frequency-diff.pl --input p1_p2_java.sync --output-prefix p1_p2 --min-count 6 --min-coverage 10 --max-coverage 200```  



#### Calculate Fst for every SNP

* Folder: /scratch/genomics/piranir/BAM_files_Anolis/BAM
	
	* Job file: fst.job

                          
  		+ **module**: ```source /home/ariasc/.bashrc```
  		+ **module**: ```conda activate poolp2```
                                                                                                      
  		+ **command**: ```perl /home/piranir/popoolation2_1201/fst-sliding.pl --input p1_p2_java.sync --output p1_p2.fst --suppress-noninformative --min-count 6 --min-coverage 10 --max-coverage 200 --min-covered-fraction 1 --window-size 1 --step-size 1 --pool-size 500```  


#### Results:
(base) -bash-4.2$ wc p1_p2.fst                                                                                                        
  46023783  276142698 2778394964 p1_p2.fst


                                                                                                                              
#### Here we will convert Fst file into .igv format for future analysis on R

* Folder: /scratch/genomics/piranir/BAM_files_Anolis/BAM
	* Job file: fst-igv.job
	

  		+ **module**: ```source /home/ariasc/.bashrc``` 
  		+ **module**: ```conda activate poolp2``` 
                                                                                                                                      
  		+ **command**: ```perl /home/piranir/popoolation2_1201/export/pwc2igv.pl --input p1_p2.fst --output p1_p2_fst.igv```  


                                                                                                                                
#### Fisher's Exact Test: estimate the significance of allele frequency differences

* Folder: /scratch/genomics/piranir/BAM_files_Anolis/BAM
	* Job file: fisher_test.job


  		+ **module**: ```source /home/ariasc/.bashrc``` 
  		+ **module**: ```conda activate poolp2``` 
                                                                                                                                      
  		+ **command**: ```perl /home/piranir/popoolation2_1201/fisher-test.pl --input p1_p2_java.sync --output p1_p2.fet --min-count 6 --min-coverage 10 --max-coverage 200 --suppress-noninformative```  



#### Here we will convert fet file into .igv format for future analysis on R

* Folder: /scratch/genomics/piranir/BAM_files_Anolis/BAM
	* Job file: fet-igv.job


  		+ **module**: ```source /home/ariasc/.bashrc``` 
  		+ **module**: ```conda activate poolp2``` 
                                                                                                                                      
  		+ **command**: ```perl /home/piranir/popoolation2_1201/export/pwc2igv.pl --input p1_p2.fet --output p1_p2_fet.igv```  



* Explanation why we use IGV files: IGV (Integrative Genomics Viewer: https://www.broadinstitute.org/igv/)  
                                                                      


## STEP 2: preparing the files for R



* For this step I am using the github Manhattan_plots (https://github.com/Gammerdinger/Manhattan_plots)																

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









