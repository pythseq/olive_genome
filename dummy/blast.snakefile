import pandas as pd
import pysam
                        
# rule all:
#    input:
#        dynamic("outputs/Oe6/blast/tab/{contig_names}.tab"),
#        dynamic("outputs/sylvestris/blast/tab/{contig_names}.tab")

rule download_Oe6_inputs_blast:
    output: 'inputs/Oe6/Oe6.scaffolds.fa'
    shell:'''
    	wget -O inputs/Oe6/Oe6.scaffolds.fa.gz https://osf.io/3mkv8/download?version=1
    	gunzip inputs/Oe6/Oe6.scaffolds.fa.gz 
	'''
	
rule download_sylv_inputs_blast:
    output: 'inputs/sylvestris/Olea_europaea_1kb_scaffolds.fa.gz'  
    shell:'''
		wget -O {output} https://osf.io/dzse9/download?version=2
    '''

rule samtools_index_Oe6:
    output: 'inputs/Oe6/Oe6.scaffolds.fa.fai'
    input: 'inputs/Oe6/Oe6.scaffolds.fa'
    conda: "envs/env.yml"
    shell:'''
    	samtools faidx {input}
    '''
    
rule expand_sylvestris:
    output: 'inputs/sylvestris/Olea_europaea_1kb_scaffolds.fa'
    input: 'inputs/sylvestris/Olea_europaea_1kb_scaffolds.fa.gz'
    shell:'''
    	gunzip {input}
    '''
    
rule samtools_index_sylvestris:
    output: 'inputs/sylvestris/Olea_europaea_1kb_scaffolds.fa.fai'
    input: 'inputs/sylvestris/Olea_europaea_1kb_scaffolds.fa'
    conda: "envs/env.yml"
    shell:'''
    	samtools faidx {input}
    '''
    
subworkflow tetramernucleotide_clustering:
    workdir: "tetramernucleotide"
    snakefile: "tetramernucleotide/tetramernucleotide.snakefile"

rule grab_suspicious_contigs_Oe6:
    output: dynamic('outputs/Oe6/suspicious_contigs/{contig_names}.fa')
    input: 
        contigs=tetramernucleotide_clustering('outputs/Oe6/suspicious_contigs.txt'),
        genome = 'inputs/Oe6/Oe6.scaffolds.fa',
        fai = 'inputs/Oe6/Oe6.scaffolds.fa.fai' 
    run:
        fasta = pysam.Fastafile(filename = input.genome)
        f=open(input.contigs,'r')
        for line in f.readlines():
            # strip white space
            line = line.strip()
            # use pysam to grab the line of interest
            fasta_of_interest = fasta.fetch(line)
            with open(f"outputs/Oe6/suspicious_contigs/{line}.fa", "w") as text_file:
                # write content of fasta file with appropriate header and sequence
                text_file.write(f">{line}\n{fasta_of_interest}")    

rule grab_suspicious_contigs_sylv:
    output: dynamic('outputs/sylvestris/suspicious_contigs/{contig_names_sylv}.fa')
    input: 
        contigs = tetramernucleotide_clustering('outputs/sylvestris/suspicious_contigs.txt'),
        genome = 'inputs/sylvestris/Olea_europaea_1kb_scaffolds.fa',
        fai = 'inputs/sylvestris/Olea_europaea_1kb_scaffolds.fa.fai' 
    run:
        fasta = pysam.Fastafile(filename = input.genome)
        f=open(input.contigs,'r')
        for line in f.readlines():
            # strip white space
            line = line.strip()
            # use pysam to grab the line of interest
            fasta_of_interest = fasta.fetch(line)
            with open(f"outputs/sylvestris/suspicious_contigs/{line}.fa", "w") as text_file:
                # write content of fasta file with appropriate header and sequence
                text_file.write(f">{line}\n{fasta_of_interest}")    
 
num = ['00', '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50', '51']

rule install_blast_db:
    output: expand('inputs/blast_db/nt.{n}.tar.gz', n = num)
    shell:'''
        cd inputs/blast_db
    	wget 'ftp://ftp.ncbi.nlm.nih.gov/blast/db/nt.*.tar.gz'
    	cat nt.*.tar.gz | tar -zxvi -f - -C .
    '''
   
rule blast_low_similarity_contigs_Oe6: 
    output: 'outputs/Oe6/blast/asn/{contig_names}.asn'
    input: 
        contig='outputs/Oe6/suspicious_contigs/{contig_names}.fa',
        db=expand('inputs/blast_db/nt.{n}.tar.gz', n = num)
    conda: "envs/env.yml"
    shell:'''
    	blastn -query {input.contig} -db inputs/blast_db/nt -outfmt 11 -out {output}
    '''

rule blast_low_similarity_contigs_sylv: 
    output: 'outputs/sylvestris/blast/asn/{contig_names_sylv}.asn'
    input: 
        contig='outputs/sylvestris/suspicious_contigs/{contig_names_sylv}.fa',
        db=expand('inputs/blast_db/nt.{n}.tar.gz', n = num)
    conda: "envs/env.yml"
    shell:'''
    	blastn -query {input.contig} -db inputs/blast_db/nt -outfmt 11 -out {output}
    '''

rule convert_blast_to_tab:
    output: 'outputs/Oe6/blast/tab/{contig_names}.tab'
    input: 'outputs/Oe6/blast/asn/{contig_names}.asn'
    conda: "envs/env.yml"
    shell:'''
    	blast_formatter -archive {input} -outfmt 6 -out {output}
    '''

rule convert_blast_to_tab_sylv:
    output: 'outputs/sylvestris/blast/tab/{contig_names_sylv}.tab'
    input: 'outputs/sylvestris/blast/asn/{contig_names_sylv}.asn'
    conda: "envs/env.yml"
    shell:'''
    	blast_formatter -archive {input} -outfmt 6 -out {output}
    '''