# rule all:
#     include:
#         'outputs/sourmash_lca/Oe6.scaffolds-k31.fa.lca.txt',
#         'outputs/sourmash_lca/Olea_europaea_1kb_scaffolds-k31.lca.txt'

rule download_Oe6_inputs_lca:
    output: 'inputs/Oe6/Oe6.scaffolds_lca.fa.gz'
    shell:'''
    	wget -O {output} http://denovo.cnag.cat/genomes/olive/download/Oe6/Oe6.scaffolds.fa.gz
    '''
	
rule download_sylv_inputs_lca:
    output: 'inputs/sylvestris/Olea_europaea_1kb_scaffolds_lca.fa.gz'  
    shell:'''
		wget -O {output} http://olivegenome.org/genome_datasets/Olea_europaea%3E1kb_scaffolds.gz
	'''

rule compute_sourmash_signature_Oe6_k31:
   output: 'outputs/Oe6/Oe6.scaffolds-k31.fa.sig'
   input: 'inputs/Oe6/Oe6.scaffolds_lca.fa.gz'
   conda:  "envs/env.yml"
   shell:'''
   # compute tetranucleotide frequency of scaffolds
   	sourmash compute -k 31 --scaled 10000 -o {output} {input}
   '''
   
rule compute_sourmash_signature_sylv_k31:
   output: 'outputs/sylvestris/Olea_europaea_1kb_scaffolds-k31.fa.sig'
   input: 'inputs/sylvestris/Olea_europaea_1kb_scaffolds_lca.fa.gz'
   conda: "envs/env.yml"
   shell:'''
   # compute tetranucleotide frequency of scaffolds
   	sourmash compute -k 31 --scaled 10000 -o {output} {input}
   '''

rule setup_sourmash_lca:
    output: 'inputs/genbank_lca/genbank-k31.lca.json.gz'
    shell:'''
    	wget -O inputs/genbank_lca/genbank-k31.lca.json.gz https://osf.io/zskb9/download
    '''
    
rule run_sourmash_LCA_Oe6:
    output: 'outputs/sourmash_lca/Oe6.scaffolds-k31.fa.lca.txt'
    input:
        genbank='inputs/genbank_lca/genbank-k31.lca.json.gz',
        sig='outputs/Oe6/Oe6.scaffolds-k31.fa.sig'
    conda: "envs/sourmash-lca.yml"
    shell:'''
    	sourmash lca classify --db {input.genbank} --query {input.sig} -o {output}
    '''

rule run_sourmash_LCA_sylv:
    output: 'outputs/sourmash_lca/Olea_europaea_1kb_scaffolds-k31.lca.txt'
    input:
        genbank='inputs/genbank_lca/genbank-k31.lca.json.gz',
        sig='outputs/sylvestris/Olea_europaea_1kb_scaffolds-k31.fa.sig'
    conda: "envs/sourmash-lca.yml"
    shell:'''
    sourmash lca classify --db {input.genbank} --query {input.sig} -o {output}
    '''