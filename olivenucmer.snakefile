# rule all: 
#    input: 'outputs/olive_genomes_nucmer/sylvester_santander_nucmer_filter_coords.txt'
    
rule download_Oe6_inputs_olive_nucmer:
    output: 
        gz='inputs/Oe6/Oe6.scaffolds_olive_nucmer.fa.gz',
        uncmp='inputs/Oe6/Oe6.scaffolds_olive_nucmer.fa'
    shell:'''
    wget -O {output.gz} http://denovo.cnag.cat/genomes/olive/download/Oe6/Oe6.scaffolds.fa.gz 
    gunzip -c {output.gz} > {output.uncmp}
	'''

rule download_sylv_inputs_olive_nucmer:
    output: 
        gz='inputs/sylvestris/Olea_europaea_chromosome+unchromosome.fa.gz',
        uncmp='inputs/sylvestris/Olea_europaea_chromosome+unchromosome.fa'
    shell:'''
	wget -O {output.gz} http://olivegenome.org/genome_datasets/Olea_europaea_chromosome+unchromosome.gz 
	gunzip -c {output.gz} > {output.uncmp}
	'''

rule olive_genomes_nucmer:
    output: 'outputs/olive_genomes_nucmer/sylvester_santander_nucmer.delta'
    input:
        sylv='inputs/sylvestris/Olea_europaea_chromosome+unchromosome.fa',
        Oe6='inputs/Oe6/Oe6.scaffolds_olive_nucmer.fa'
    conda: "envs/env.yml"
    shell:'''
    nucmer --mum {input.sylv} {input.Oe6} -p outputs/olive_genomes_nucmer/sylvester_santander_nucmer
    '''
    
rule olive_genome_nucmer_filter:
    output: 'outputs/olive_genomes_nucmer/sylvester_santander_nucmer_filter.delta'
    input: 'outputs/olive_genomes_nucmer/sylvester_santander_nucmer.delta'
    conda: "envs/env.yml"
    shell:'''
    delta-filter -l 500 -q {input} > {output}
    '''
    
rule olive_genome_nucmer_coords:
    output: 'outputs/olive_genomes_nucmer/sylvester_santander_nucmer_filter_coords.txt'
    input: 'outputs/olive_genomes_nucmer/sylvester_santander_nucmer_filter.delta'
    conda: "envs/env.yml"
    shell:'''
    show-coords -c -l -L 500 -r -T {input} > {output}
    '''