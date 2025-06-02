#! /bin/bash
#$ -S /bin/bash
#$ -wd /net/dunham/vol2/TKWang/clb2_progeny
#$ -o /net/dunham/vol2/TKWang/clb2_progeny/WorkDirectory
#$ -e /net/dunham/vol2/TKWang/clb2_progeny/errors
#$ -l mfree=8G
#$ -l h_rt=36:0:0

##Pipeline to align WGS from Illumina to a reference genome (NO SNP calling)
##first part of Illumina WGS pipeline for aligning against a reference genome.

module load modules modules-init modules-gs
module load java/1.17
module load trimmomatic/0.39

FOLDER=$1 #folder name containing fastqs. Will be within DIR
SAMPLE=$2 #sample prefix directly before _R*.fastq.gz
DIR=/net/dunham/vol2/TKWang/clb2_progeny/ #parent directory to fastqs, scripts, output, etc
WORKDIR=${DIR}/WorkDirectory #Location for output files, use mkdir to create
RAWSEQDIR=${DIR}/${FOLDER} #where the raw fastq files are (first argument of script)
TRIMSEQDIR=${WORKDIR}/${SAMPLE}/trim #where the trimmed fastq files are made
SEQID=YTW164 #Project name and date for bam header (NOT for each individual sample file)
REF=/net/dunham/vol2/TKWang/clb2_progeny/genomes/hybrid_ref.fasta

#set up folder structure 
cd ${WORKDIR}
mkdir -p ${WORKDIR}/${SAMPLE}
cd ${WORKDIR}/${SAMPLE}

#Check the directory dependencies and definitions
echo ${WORKDIR}
echo ${RAWSEQDIR}
echo ${TRIMSEQDIR}

##This part will trim adaptor sequences from your raw .fastq files 
##Need to tell the program if it is PE or SE reads

mkdir trimlog trim untrim

(>&2 echo ***Trimmomatic***)
java -jar ${MOD_GSTRIMMOMATIC_DIR}/trimmomatic-0.39.jar PE -phred33 -trimlog ${WORKDIR}/${SAMPLE}/trimlog/${SAMPLE}.txt ${RAWSEQDIR}/${SAMPLE}_*R1*.fastq.gz ${RAWSEQDIR}/${SAMPLE}_*R2*.fastq.gz ${WORKDIR}/${SAMPLE}/trim/${SAMPLE}_R1_trim.fastq.gz ${WORKDIR}/${SAMPLE}/untrim/${SAMPLE}_R1_untrim.fastq.gz ${WORKDIR}/${SAMPLE}/trim/${SAMPLE}_R2_trim.fastq.gz ${WORKDIR}/${SAMPLE}/untrim/${SAMPLE}_R2_untrim.fastq.gz
ILLUMINACLIP:/net/dunham/vol2/TKWang/clb2_progeny/adapters/NexteraPE-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36