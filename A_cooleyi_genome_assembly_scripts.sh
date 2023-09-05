#Canu: only corrected reads were used in our assembly pipeline

canu \
 -p Ac_flye -d Ac_flye_pbio \
 genomeSize=270m \
 -pacbio Ac_flye.fasta

#Flye

/apps/eb/Flye/2.9-foss-2019b-Python-3.8.2/bin/flye --pacbio-corr Ac_canu.correctedReads.fasta -i 5 --threads 32 --o-dir Ac_flye_corrected_reads_scaf --scaffold

#Arks

arcs-make arks-long draft=ACOO_flye_CR reads=Ac_canu.correctedReads m=8-10000 c=4 l=4 a=0.3 k=20 j=0.05

#Rails/cobbler

./runRAILSminimap.sh ACOO_flye_CR_arks_CR.fa ../Ac_canu.correctedReads.fa 250 0.8 250bp 2 pacbio /home/dtdial/samtools-1.8/samtools

#Tigmint

tigmint-make tigmint-long draft=ACOO_flye_CR_arks_rails_CR reads=Ac_canu.correctedReads span=ao G=272898873 dist=ao longmap=pb t=12


#Transcript read mapping with hisat (raw rna-seq data trimmed with trimmomatic)

hisat2-build ACOO_flye_CR_arks_rails_tigmint_CR_rn_format_100.fa ACOO_flye_hisat

hisat2 -x ACOO_flye_hisat -1 acoo_transcriptome_R1_paired_SW25.fastq.gz -2 acoo_transcriptome_R2_paired_SW25.fastq.gz -k 3 -p 24 --pen-noncansplice 1000000 -S ACOO_flye_vs_transcriptome_hisat.sam

#P_RNA_Scaffolder command:

P_RNA_scaffolder.sh -d /home/dtdial/P_RNA_scaffolder-master/ -i ACOO_flye_vs_transcriptome_hisat.sam -j ACOO_flye_CR_arks_rails_tigmint_CR_rn_format_100.fa -F acoo_transcriptome_R1_paired_SW25.fastq.gz -R acoo_transcriptome_R2_paired_SW25.fastq.gz -t 20 -o P_RNA_scaffolder -f 5 -b no
