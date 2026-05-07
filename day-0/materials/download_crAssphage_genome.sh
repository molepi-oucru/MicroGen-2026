#!/bin/bash
# Download the crAssphage - Carjivirus communis - reference genome from NCBI

# Create a directory to store the genome
mkdir -p crAssphage 

# Download the genome sequence in FASTA format
wget "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&id=NC_067194.1&rettype=fasta&retmode=text" -O crAssphage/NC_067194.1.fasta

# Download the genome annotation in GenBank format
wget "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&id=NC_067194.1&rettype=gb&retmode=text" -O crAssphage/NC_067194.1.gbk

# List the downloaded files
ls -lh crAssphage/
