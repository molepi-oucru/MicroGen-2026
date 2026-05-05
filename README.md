# Beginner Course on Microbial Genomics: Applications & Research

A bioinformatics workshop organised by the [Molecular Epidemiology Group](https://www.oucru.org/research/molecular-epidemiology) at Oxford University Clinical Research Unit in May, 2026.

This workshop is a part of the [KLEB-CASAVA](https://www.oucru.org/project/kleb-casava/) project, funded by the UKRI.

Aiming to enhance the local capacity in genomic epidemiology and surveillance, the workshop provides essential bioinformatics skills for Vietnamese clinicians and researchers, whose work focuses on bacterial infectious diseases, but have little to no experience in analysing whole-genome sequencing data. 

**Instructors:**
  - Dr. Pham Thanh Duy (Duy), Center for Tropical Medicine and Global Health, Nuffield Department of Clinical Medicine, Oxford University
  - Dr. Chung The Hao (Hao), Saw Swee Hock School of Public Health, National University of Singapore
  - Mai Thu Si Nguyen (Nguyen), Oxford University Clinical Research Unit
  - Nguyen Pham Nhu Quynh (Quynh), Center for Tropical Medicine and Global Health, Nuffield Department of Clinical Medicine, Oxford University
  - Ton Ngoc Minh Quan (Quan), Oxford University Clinical Research Unit

## Navigating

The materials are organised by day of the workshop, following the program below.

Within each day, there are three directories: 

- `instructions` : Practical guides
- `materials` : Input files required to work on practicals; and corresponding expected outputs
- `slides` : lecture slides

## Lectures & Credits

### Day 0: Pack your backpack (Pre-Workshop)

- **0.1 Setup your workspace** - Quan
- **0.2 Commands & Environments** - Nguyen

### Day 1: Meet the genomes

- **1.1 Whole-genome sequencing - What? & Why?** - Hao, Quynh
- **1.2 A complete genome - How it look like?** - Duy
- **1.3 From raw sequencing data to assemblies** - Nguyen

### Day 2: Inspect the genomes

- **2.1 Analyse the assemblies** - Quynh, Quan
- **2.2 Long-read sequencing & Hybrid assemblies** - Quynh
- **2.3 Locate & compare genes** - Nguyen

### Day 3: Genomic variations and relationships

- **3.1 Read mapping** - Hao
- **3.2 Phylogenetics** - Hao

### Day 4: Next-generation Metagenomic sequencing (mNGS)

**Module: mNGS in clinical microbiology** - Hao & Quan

- **4.1: Workflow setup**
- **4.2: Taxonomy analysis**
- **4.3: AMR analysis and summary**

**Module: mNGS in pathogen detection** - Quan & Hao

- **4.4: Clinical case**
- **4.5: Signal analysis**

Day 4 introduces read-based metagenomic analysis for two teaching scenarios: a six-sample Vietnamese healthy gut microbiome / AMR surveillance re-analysis, and a clinical case study focused on actionable diagnosis. Backup analysis files are provided in `day-4/materials/` so participants can continue the interpretation exercises even if they cannot complete a live run during the workshop.


## Datasets

Public datasets that have been used for practicals along the course:
- Capitani *et al*,  Hospital outbreak sustained by Klebsiella pneumoniae sequence type 147 co-producing NDM-1 and OXA-48, Rome, Italy, February to March 2025: molecular tracing and control measures. Euro Surveill. 2026;31(10):pii=2500457. https://doi.org/10.2807/1560-7917.ES.2026.31.10.2500457. BioProject ID: PRJNA1260529.
- Pereira-Dias *et al*, The Gut Microbiome of Healthy Vietnamese Adults and Children Is a Major Reservoir for Resistance Genes Against Critical Antimicrobials. *Journal of Infectious Diseases*. 2021;224(S7):S840-S847. https://doi.org/10.1093/infdis/jiab398.
- Wilson *et al*, Actionable Diagnosis of Neuroleptospirosis by Next-Generation Sequencing. *New England Journal of Medicine*. 2014;370:2408-2417. https://doi.org/10.1056/NEJMoa1401268. BioProject ID: PRJNA234452.

