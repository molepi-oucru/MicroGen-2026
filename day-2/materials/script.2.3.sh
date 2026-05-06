#!/bin/bash
################################################################################
# Beginner Course on Microbial Genomics: Applications & Research
# 2026. Molecular Epidemiology Group, Oxford University Clinical Research Unit.
#---------------
# Module 2.3: Locate & compare genes
# Instructor: Nguyen MTS 
################################################################################

################################################################################
#
# 1. Genome annotation -- Locate genes on assembly sequences
#
################################################################################

#---------------#
# Annotation using Bakta v1.6.1
# Bakta DB version 4.0 2022-08-29
#---------------#
conda activate microgen2026_bakta
BAKTA_DB="/databases/bakta/db"

mkdir -p bakta_output

while read -r sampleID; do
    contig_file="unicycler_shortread/${sampleID}.assembly.fasta";
    bakta --db ${BAKTA_DB} --genus Klebsiella --gram '-' \
            --prefix ${sampleID} --output "bakta_output/"${sampleID} \
            --threads 8 ${contig_file};
done < <(cut -f1 samples_shortread.tsv)

for sampleID in "951Kp" "949Kp"; do
    contig_file="unicycler_longread/${sampleID}.assembly.fasta";
    bakta --db ${BAKTA_DB} --genus Klebsiella --gram '-' \
            --prefix ${sampleID} --output "bakta_output/"${sampleID} \
            --threads 8 ${contig_file};
done

################################################################################
#
# 2. View annotated assembly on Artemis
#
################################################################################

# We will use Artemis to view the annotated assembly of sample 951Kp
# One important note is that our assembly contains multiple contigs, and 
# the Bakta annotation .gbff file contains annotations for all contigs (each termed as "LOCUS").
# However, Artemis can only open one locus at a time. 
# So we will need to split the .gbff file into multiple files, one for each contig (or "LOCUS").

# Checking the .gbff file of sample 951Kp,
# You shall see that there are 4 LOCUS in total.
grep -w "^LOCUS\t" bakta_output/951Kp/951Kp.gbff

# LOCUS       contig_1             5444787 bp    DNA     linear   UNK 19-APR-2026
# LOCUS       contig_2              108854 bp    DNA     linear   UNK 19-APR-2026
# LOCUS       contig_3               45203 bp    DNA     linear   UNK 19-APR-2026
# LOCUS       contig_4               13633 bp    DNA     linear   UNK 19-APR-2026

# This is actually from long-read sequencing, so we can see one very large contig up to 5.4 Mb.
# This is highly likely the complete chromosome of the bacterium.
# While the other contigs are likely plasmids.

# Let's split the .gbff file into multiple files, one for each contig (or "LOCUS").
csplit --prefix "bakta_output/951Kp/951Kp.contig_" -n 1 bakta_output/951Kp/951Kp.gbff '/LOCUS/' '{*}'

# Check the output files
ls -l bakta_output/951Kp/951Kp.contig_*

# Rename file for the chromosome
mv bakta_output/951Kp/951Kp.contig_0 bakta_output/951Kp/951Kp.chromosome.gbff

# Rename files for the plasmids
mv bakta_output/951Kp/951Kp.contig_1 bakta_output/951Kp/951Kp.plasmid_1.gbff
mv bakta_output/951Kp/951Kp.contig_2 bakta_output/951Kp/951Kp.plasmid_2.gbff
mv bakta_output/951Kp/951Kp.contig_3 bakta_output/951Kp/951Kp.plasmid_3.gbff

# Open the chromosome file with Artemis
art /microgen2026/day-2/bakta_output/951Kp/951Kp.chromosome.gbff &

################################################################################
#
# 3. Extract & Merge gyrA sequences of all samples
#
################################################################################

allSeqs="gyrA.sequences.ffn"

for dir in bakta_output/*/; do
    sample=$(basename $dir);
    gyrA_id=$(grep -w "gyrA" ${dir}/${sample}.tsv | cut -f6);
    if [[ $gyrA_id != "" ]]; then
        grep -w ">${gyrA_id}" -A 1 ${dir}/${sample}.ffn | sed "s/>/>$sample /g" >> $allSeqs;
    else
        echo Cannot find gyrA in Bakta annotation of sample ${sample};
    fi;
done

# Print sequence names & lengths
awk ' {if ($0 ~ /^>/) {print $0;} else {print length;}}' $allSeqs

# Open the file in Seaview
seaview $allSeqs

# Add the reference sequence
cp $allSeqs gyrA.sequences.plusRef.ffn
cat gyrA-reference-kleborate.fast >> gyrA.sequences.plusRef.ffn

# Open the file in Seaview
seaview gyrA.sequences.plusRef.ffn

