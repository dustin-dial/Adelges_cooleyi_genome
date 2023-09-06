#!/bin/bash
#SBATCH --partition=highmem_p
#SBATCH --job-name=blobtools.sh
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --time=10:00:00
#SBATCH --mem=200gb

cd $SLURM_SUBMIT_DIR

ml EMBOSS/6.6.0-GCC-8.3.0-Java-11
ml DIAMOND/2.0.4-GCC-8.3.0
ml SAMtools/1.10-iccifort-2019.5.281
ml minimap2/2.17-GCC-8.3.0

#read mapping

minimap2 -t 10 -ax map-pb scaffolds.fasta subreads.fasta --secondary=no \
    | samtools sort -o scaffolds_vs_subreads.bam -T tmp.ali

#call ORFs on contigs and search against refseq

getorf -minsize 100 -find 1 -sequence scaffolds.fasta -outseq scaffolds_ORFs.fasta

diamond blastp --threads 8 -d /work/grblab/custom_refseq_db_dd.dmnd -q scaffolds_ORFs.fasta -o scaffolds_ORFs_vs_custom_refseq_db.m8 --outfmt 6 qseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore staxids salltitles --max-target-seqs 1 --max-hsps 1 --evalue 0.001 --threads 8 1>job.out 2>job.err

perl /work/grblab/convert_hitsfile_blob.pl scaffolds_ORFs_vs_custom_refseq_db.m8 scaffolds_ORFs_vs_custom_refseq_db_format.m8.txt

#blobtools

blobtools create -i scaffolds.fasta -b scaffolds_vs_subreads.bam -t scaffolds_ORFs_vs_custom_refseq_db_format.m8.txt -o blobtools

#Next, you can use blobtools to create your plots and tables:

#this next "view" command gives you the taxonomic rank of all of your scaffolds, e.g. phylum, order, family, genus, species

blobtools view -r all -i blobtools.json --out blobtools

blobtools plot -i blobtools.json -o ./

grep "Arthropoda" blobtools.blobDB.table.txt > blobtools.blobDB.table_Arthropoda.txt

cat blobtools.blobDB.table_Arthropoda.txt | cut -f 1 > blobtools.blobDB.table_Arthropoda_list.txt 

perl /home/dtdial/grab_seq.pl scaffolds.fasta blobtools.blobDB.table_Arthropoda_list.txt > blobtools.blobDB.table_Arthropoda_list.fasta
