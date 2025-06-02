# hybrid-meiotic-null
Custom scripts for “Meiotic null MSH2 and SGS1 alleles in S. cerevisiae x S. uvarum hybrids result in parahaploid offspring with mixed parental chromosomal inheritance.”

First run the alignment pipeline bash script to align raw fastq files to reference genome. Run trimmomatic first, then notrim_noMM_align.bash. This will automatically use samtools depth on the final .bam file to generate the .txt file that will be fed into the custom Rscript for CNV analysis and plotting.
