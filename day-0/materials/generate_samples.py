import os
import random

def generate_fasta(filename, contigs):
    with open(filename, 'w') as f:
        for name, seq in contigs:
            f.write(f">{name}\n")
            # Write sequence in 60-char lines
            for j in range(0, len(seq), 60):
                f.write(f"{seq[j:j+60]}\n")

def get_seq(length):
    return "".join(random.choice("ACGT") for _ in range(length))

output_dir = "/data/MicroGen-2026/day-0/materials"
os.makedirs(output_dir, exist_ok=True)

# Define varying properties for each sample
sample_configs = {
    "sample_A": {"num_contigs": 2, "len_range": (100, 300)},
    "sample_B": {"num_contigs": 5, "len_range": (50, 150)},
    "sample_C": {"num_contigs": 1, "len_range": (1000, 1200)},
    "sample_D": {"num_contigs": 3, "len_range": (200, 600)},
}

# Generate short-read samples
for name, config in sample_configs.items():
    contigs = []
    for i in range(config["num_contigs"]):
        length = random.randint(*config["len_range"])
        contigs.append((f"contig_{i+1}", get_seq(length)))
    generate_fasta(os.path.join(output_dir, f"{name}.fasta"), contigs)

# Generate longread sample
longread_contigs = [
    ("long_contig_1", get_seq(12000)),
    ("long_contig_2", get_seq(8000)),
    ("long_contig_3", get_seq(15000))
]
generate_fasta(os.path.join(output_dir, "sample_B.longread.fasta"), longread_contigs)

print(f"Generated FASTA files with varying contigs in {output_dir}")
