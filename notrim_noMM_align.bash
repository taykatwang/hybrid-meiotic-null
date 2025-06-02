#! /bin/bash
#$ -S /bin/bash
#$ -wd /net/dunham/vol2/TKWang/clb2_progeny/final_cnv
#$ -o /net/dunham/vol2/TKWang/clb2_progeny/final_cnv
#$ -e /net/dunham/vol2/TKWang/clb2_progeny/final_cnv/error
#$ -l mfree=8G
#$ -l h_rt=36:0:0

##Pipeline to align WGS from Illumina to a reference genome (NO SNP calling)
##first part of Illumina WGS pipeline for aligning against a reference genome.

module load modules modules-init modules-gs
module load bwa/0.7.15
module load samtools/1.19
module load java/1.17
module load picard/3.1.1

FOLDER=$1 #folder name containing fastqs. Will be within WORKDIR
SAMPLE=$2 #sample prefix directly before _R*.fastq.gz
DIR=/net/dunham/vol2/TKWang/clb2_progeny/final_cnv #parent directory to fastqs, scripts, output, etc
WORKDIR=${DIR}/AlignDirectory #Location for output files, use mkdir to create
TRIMSEQDIR=${DIR}/${FOLDER} #where the trimmed fastq files are made
SEQID=YTW164_c1 #Project name and date for bam header (NOT for each individual sample file)
REF=/net/dunham/vol2/TKWang/alignment/bwamem/reference/hybrid_ref.fasta

#set up folder structure
cd ${WORKDIR}
mkdir -p ${WORKDIR}/${SAMPLE}
cd ${WORKDIR}/${SAMPLE}

mkdir trimlog trim untrim
#Take the trimmed read output from trimmomatic and feed it into bwa mem

(>&2 echo ***BWA - mem -R***)
bwa mem -R '@RG\tID: '${SEQID}'\tSM: '${SAMPLE}'\tLB:1' ${REF} ${TRIMSEQDIR}/${SAMPLE}_*R1*.fastq.gz ${TRIMSEQDIR}/${SAMPLE}_*R2*.fastq.gz > ${SAMPLE}_R1R2.sam

#Use a grep filter to find adn remove and multimapping reads XA:Z and SA:Z tagged reads
grep -v -e 'XA:Z:' -e 'SA:Z:' ${SAMPLE}_R1R2.sam > ${SAMPLE}_noMM_R1R2.sam

#Convert the .sam file into a .bam
(>&2 echo ***Samtools - View***)
samtools view -b -h ${SAMPLE}_noMM_R1R2.sam -o ${SAMPLE}_noMM_R1R2.bam 

#Sort the .bam file to make analysis faster
(>&2 echo ***Samtools - Sort***)
samtools sort ${SAMPLE}_noMM_R1R2.bam -o ${SAMPLE}_sort_noMM_R1R2.bam

cd ${WORKDIR}/${SAMPLE}

mkdir -p dup_metrics

#Run Picard on the sorted .bam to remove PCR duplicates
(>&2 echo ***Picard - MarkDuplicates***)
java -Xmx2g -jar ${PICARD_DIR}/picard.jar MarkDuplicates \
		INPUT=${SAMPLE}_sort_noMM_R1R2.bam \
		OUTPUT=${SAMPLE}_noMM_R1R2_MD.bam \
		METRICS_FILE=dup_metrics/${SAMPLE}_noMM_R1R2_MD_dupmetrics.txt \
		REMOVE_DUPLICATES=true \
		VALIDATION_STRINGENCY=LENIENT
		
#Sort the output .bam from Picard that has had PCR duplicates removed
(>&2 echo ***Samtools - Sort***)
samtools sort ${SAMPLE}_noMM_R1R2_MD.bam -o ${SAMPLE}_sort_noMM_R1R2_MD.bam

#Index this .bam for viewing of alignment in IGV
(>&2 echo ***Samtools - Index***)
samtools index ${SAMPLE}_sort_noMM_R1R2_MD.bam

##Export depth file via samtools for R CNV analysis and plotting script
(>&2 echo ***Samtools - Depth***)
samtools depth -a ${SAMPLE}_sort_noMM_R1R2_MD.bam > ${SAMPLE}_noMM_R1R2_MD_depth.txt