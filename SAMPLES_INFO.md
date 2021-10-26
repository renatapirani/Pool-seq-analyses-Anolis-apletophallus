# POPLSEQ _ANOLIS APLETOPHALLUS_ 

## 2 MAIN FOLDER: 


* FOLDER: Sample_WOM_B01_2-1259687 (49 ind, bicolor dewlap)

files names: WOM_B01_2-1259687_S1_L001_R1_001.fastq.gz, WOM_B01_2-1259687_S1_L001_R2_001.fastq.gz

 

* FOLDER: Sample_WOM_S02_2-1259687 (49 ind, solid dewlap)
	
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
											 
* comparing this 2 populations -> the solid dewlap pop and the bicolor dewlap pop.   	
* use a reference genome --> shaune-smi2505-mb-hirise-gd6od__06-26-2021__hic_output.fasta <-- the Dovetail genome	
* some times you need to prepare the genome before using it. 
* For this use the script (prep_genome.sh)
* Help: http://broadinstitute.github.io/picard/command-line-overview.html -> CreateSequenceDictionary

* 1 JOB: /scratch/genomics/piranir/poolparty/example/prep_bwa.job
 
  		+ **module**: ```module load bioinformatics/bwa/0.7.17```
 		
  		+ **module**: ```bwa index -a bwtsw shaune-smi2505-mb-hirise-gd6od__06-26-2021__hic_output.fasta```
 
                                                                                                                       
* 2 JOB: prep_samtools.job


  		+ **module**: ```module load bioinformatics/samtools```                                                                                                                                       
                                                                                             
  		+ **module**: ```samtools faidx shaune-smi2505-mb-hirise-gd6od__06-26-2021__hic_output.fasta```                                                                                                                                             


* 3 JOB: prep_java.job

  		+ **module**: ```module load bioinformatics/picard-tools/2.20.6```  
                                                                                                                                      
  		+ **module**: ```java -jar picard.jar CreateSequenceDictionary \```                                                                                                                                             
  		+ **module**: ```R=shaune-smi2505-mb-hirise-gd6od__06-26-2021__hic_output.fasta \```                                                                                            
  		+ **module**: ```O=shaune-smi2505-mb-hirise-gd6od__06-26-2021__hic_output.fasta.dict```  



# Step 2 : Alignment 
												
	
* open the "pp_align.config" file and make the changes for this data 
	-> I am configuring it based on the results from the sequence company
	
* create the folder -> dewlapSB
* copy the folder popoolation2_1201 from /home/ariasc/programs/popoolation to your folder (do for the first time)
* download samblaster from "git clone git://github.com/GregoryFaust/samblaster.git" (do for the first time)
* HELP: install conda -  https://confluence.si.edu/display/HPC/Conda+tutorial (install R packages and everything else) (do for the first time)

	 
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


#### AFTER MANY ERRORS, PROBABLY BECAUSE OF SAMBLASTER, WE DECIDED TO RUN WITH CARLOS PROGRAMS, 
	I WILL ACCESS HIS FOLDER AND RUN POOLPARTY AS THE EXAMPLE BELOW:


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
                                                                      












