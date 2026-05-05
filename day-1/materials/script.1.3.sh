#!/bin/bash
################################################################################
# Beginner Course on Microbial Genomics: Applications & Research
# 2026. Molecular Epidemiology Group, Oxford University Clinical Research Unit.
#---------------
# Module 1.3: From raw sequencing data to assemblies
# Instructor: Nguyen MTS 
################################################################################

################################################################################
#
# 1. RAW SEQUENCING DATA
#
################################################################################

#---------------#
# Download WGS (short-read & long-read) from public project: PRJNA1260529
# Using package Kingfisher v0.4.1
#---------------#
conda activate microgen2026

# Metadata
kingfisher annotate -p PRJNA1260529 --all-columns -f tsv -o PRJNA1260529.metadata.tsv

# Sequences
kingfisher get -p PRJNA1260529 --output-directory PRJNA1260529 -m ena-ascp ena-ftp prefetch -f fastq.gz --download-threads 10 --check-md5sums

#---------------#
# Separate short-read files, and
# Rename them, from SRA Run ID to Sample ID ( as in the publication )
# Use information in metadata file 'PRJNA1260529.metadata.tsv', with
# column 1 = SRA run ID, column 28 = sample_title
# Short reads are from "Illumina MiSeq" method
#---------------#
mkdir raw_shortread

# Loop through lines in the 'PRJNA1260529.metadata.tsv' that contains the keyword "Illumina MiSeq"
# Get only column 1 and 28 as 'sra' and 'sample', respectively
while read -r sra sample; do

    # Create a copy with filename as isolate name, to the directory 'raw_shortread'
    # Do this for both forward & reverse read files
    cp PRJNA1260529/${sra}_1.fastq.gz raw_shortread/${sample}_1.fastq.gz;
    cp PRJNA1260529/${sra}_2.fastq.gz raw_shortread/${sample}_2.fastq.gz;

done < <(grep "Illumina MiSeq" PRJNA1260529.metadata.tsv | cut -f1,28)

################################################################################
#
# 2. READ QUALITY CONTROL
#
################################################################################

#---------------#
# FastQC v0.11.9
# MultiQC v1.34
#---------------#
# input directory of read files
in_dir="raw_shortread/"

# create output directory for FastQC output
fastqc_outdir="fastqc_shortread/"
mkdir -p $fastqc_outdir

# create output directory for MultiQC output
multiqc_outdir="multiqc_shortread/"
mkdir -p $multiqc_outdir

# activate Conda environment containing FastQC & MultiQC
conda activate microgen2026

# Run FastQC
nthreads=5 # number of files will be analysed parallely at a time, should be <= number of CPUs of the computer 
fastqc -o $fastqc_outdir -t $nthreads $in_dir/*.fastq.gz

# Run MultiQC on FastQC output
multiqc --interactive --force -o $multiqc_outdir $fastqc_outdir

################################################################################
#
# 3. DE NOVO ASSEMBLY
#
################################################################################

#---------------#
# Unicycler v0.5.1
# SPAdes genome assembler v4.2.0
#---------------#

# create a directory for assembly output
mkdir -p unicycler_shortread

# create a tsv file with sample names and their corresponding fastq files
while read -r sample; do
    echo -e ${sample}"\t"raw_shortread/${sample}_1.fastq.gz"\t"raw_shortread/${sample}_2.fastq.gz >> samples_shortread.tsv;
done < <(grep "Illumina MiSeq" PRJNA1260529.metadata.tsv | cut -f28)

# run unicycler on 3 samples at a time
conda activate microgen2026
parallel -j 3 --colsep "\t" unicycler -1 {2} -2 {3} -o unicycler_shortread/{1} --threads 4 :::: samples_shortread.tsv

################################################################################
#
# SELF-EXPLORATION
#
################################################################################

#---------------#
# Reads trimming using fastp
#---------------#

# Install fastp in a conda environment
mamba create -n fastp
mamba activate fastp
mamba install -c bioconda fastp

# Example: Trimming on short reads of an isolate ERR4244683
# The sample is in directory 'ugly_sample/'

# Trimming for both forward & reverse reads
# Trim the first 15 bp from front (5') end
# Move a sliding window (window length = 4bp) from tail (3') to front, 
# drop the bases in the window if its mean quality is below 25, stop otherwise. 
# Trim polyX tail
# Discard trimmed reads shorter than 50 bp
# Adapter trimming is enabled by default
mkdir -p trimming_output

fastp --in1 ugly_sample/ERR4244683_1.fastq.gz --in2 ugly_sample/ERR4244683_2.fastq.gz \
    --out1 trimming_output/ERR4244683_1.trimmed.fastq.gz --out2 trimming_output/ERR4244683_2.trimmed.fastq.gz \
    --trim_front1 15 --trim_front2 15 \
    --trim_poly_x \
    --cut_tail --cut_tail_window_size 4 --cut_tail_mean_quality 25 \
    --length_required 50 > trimming_output/fastp_run.log 2>&1

# Output includes:
# - Trimmed reads in directory 'trimming_output'
# - Run log file containing STDOUT + STDERR in directory 'trimming_output'
# - Summary files 'fastp.html' and 'fastp.json' at where the command was run
# Move the HTML and the JSON files to the directory 'trimming_output' for a neat organization

# QC the trimmed reads
cd trimming_output
mkdir -p fastqc_trimmed
mkdir -p multiqc_trimmed

conda activate microgen2026
fastqc -o fastqc_trimmed ./*.trimmed.fastq.gz
multiqc --interactive --force -o multiqc_trimmed fastqc_trimmed

# Check the MultiQC report on the trimmed reads, and 
# Compare it with that on the raw reads (in directory 'ugly_sample/multiqc_raw')
# Do you see any improvement in read quality?

#---------------#
# Species identification directly on on raw short-reads
# Using tool from metagenomics - sylph v0.9.0 
#---------------#
SYLPH_DB="/databases/sylph/gtdb-r226-c200-dbv1.syldb"
conda activate microgen2026
sylph profile $SYLPH_DB -1 raw_shortread/*_1.fastq.gz -2 raw_shortread/*_2.fastq.gz -o sylph_shortread.tsv


