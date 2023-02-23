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


# Step 1 - Genome preparation

WORK FOLDER HYDRA: /scratch/genomics/piranir/poolparty
											

* make a folder with all the fastq.gz files: S02_2-1259687_S2_L001_R1_001.fastq.gz, S02_2-1259687_S2_L001_R2_001.fastq.gz (SOLID DEWLAP)
											 B01_2-1259687_S1_L001_R1_001.fastq.gz, B01_2-1259687_S1_L001_R2_001.fastq.gz (BICOLOR DEWLAP)
											 
	** I changed the names of the files (removed the WOM_ from the beginning of the names) **
											 
* comparing the 2 morph -> the solid and bicolor dewlap   	
* use a reference genome --> AnoAple_1.1.fasta (Pirani et al. 2023)
* Preparing the genome before using it
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

* The results are presented at the Table 2



# Step 3: Stats

#### After use Popoolation2

* Folder: /scratch/genomics/piranir/dewlapSB
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


# Step 4: Analyze


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
                                                                 


## STEP 5: preparing the files for R



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









