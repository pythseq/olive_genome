import pandas as pd
import numpy as np
from sourmash_lib import signature

#rule all:
#    input:
#        'outputs/Oe6/Oe6.scaffolds-k4.comp.matrix.png',
#        'outputs/Oe6/suspicious_contigs.txt',
#        'outputs/sylvestris/suspicious_contigs.txt'

rule download_Oe6_genome_k4:
    output: 'inputs/Oe6/Oe6.scaffolds_k4.fa.gz'
    shell:'''
    wget -O {output} http://denovo.cnag.cat/genomes/olive/download/Oe6/Oe6.scaffolds.fa.gz 
	'''

rule compute_sourmash_signature_k4_Oe6:
   output: 'outputs/Oe6/Oe6.scaffolds-k4.fa.sig'
   input: 'inputs/Oe6/Oe6.scaffolds_k4.fa.gz'
   conda: "envs/env.yml"
   shell:'''
   # compute tetranucleotide frequency of scaffolds
   sourmash compute -k 4 --scaled 1 --track-abundance --singleton --name-from-first -o {output} {input}
   '''
   
rule run_sourmash_compare_Oe6:
	output: 
	    comp='outputs/Oe6/Oe6.scaffolds-k4.comp',
	    labels='outputs/Oe6/Oe6.scaffolds-k4.comp.labels.txt'
	input: 'outputs/Oe6/Oe6.scaffolds-k4.fa.sig'
	conda: "envs/env.yml"
	shell:'''
	sourmash compare -o {output.comp} {input}
	'''
	
rule plot_compare_Oe6:
    output: 'outputs/Oe6/Oe6.scaffolds-k4.comp.matrix.png'
    input: 'outputs/Oe6/Oe6.scaffolds-k4.comp'
    conda: "envs/env.yml"
    shell:'''
    sourmash plot --subsample 400 --subsample-seed 1 {input}
    '''

rule suspicious_contigs_Oe6:
    output: 
        Oe6_contigs='outputs/Oe6/suspicious_contigs.txt'
    input: 
        comp='outputs/Oe6/Oe6.scaffolds-k4.comp',
        labels='outputs/Oe6/Oe6.scaffolds-k4.comp.labels.txt'
    run:
        import statistics

        # load numpy array into python
        comp = np.load(input.comp)
        # convert to a pandas dataframe
        df = pd.DataFrame(comp)
    
        # read labels into python
        f = open(input.labels, 'r')
        labels = f.readlines()
	
        # set column names to labels
        df.columns = labels
	
        # calculate column means
        column_means = df.mean(axis=1)

        # calculate suspicion cutoff
        cutoff = statistics.mean(column_means) - 2*(statistics.stdev(column_means))
        
        # grab suspicious columns
        suspicious_columns = df.loc[:, df.mean() < cutoff]
	
        # write column names to list
        suspicious_column_names = suspicious_columns.columns.tolist()
    
        # write suspicious labels to a file
        with open(output.Oe6_contigs, 'w') as file_handler:
            for item in suspicious_column_names:
                file_handler.write("{}".format(item))

rule download_sylv_genome_k4:
    output: 
        gz='inputs/sylvestris/Olea_europaea_1kb_scaffolds.fa.gz',
        uncmp='inputs/sylvestris/Olea_europaea_1kb_scaffolds.fa'
    shell:'''
	wget -O {output.gz} http://olivegenome.org/genome_datasets/Olea_europaea%3E1kb_scaffolds.gz
	gunzip -c {output.gz} > {output.uncmp} 
	'''

rule split_sylvester:
    output: 
        'inputs/sylvestris/Olea_europaea_1kb_scaffolds.0.fa',
        'inputs/sylvestris/Olea_europaea_1kb_scaffolds.1.fa',
        'inputs/sylvestris/Olea_europaea_1kb_scaffolds.2.fa',
        'inputs/sylvestris/Olea_europaea_1kb_scaffolds.3.fa'
    input: 'inputs/sylvestris/Olea_europaea_1kb_scaffolds.fa'
    conda: "envs/env.yml"
    shell:'''
    pyfasta split -n 4 --overlap 0 {input}
    '''

rule compute_sourmash_signature_k4_sylv:
    output: 
        slice0='outputs/sylvestris/Olea_europaea_1kb_scaffolds.0.sig',
        slice1='outputs/sylvestris/Olea_europaea_1kb_scaffolds.1.sig',
        slice2='outputs/sylvestris/Olea_europaea_1kb_scaffolds.2.sig',
        slice3='outputs/sylvestris/Olea_europaea_1kb_scaffolds.3.sig'
    input:
        slice0='inputs/sylvestris/Olea_europaea_1kb_scaffolds.0.fa',
        slice1='inputs/sylvestris/Olea_europaea_1kb_scaffolds.1.fa',
        slice2='inputs/sylvestris/Olea_europaea_1kb_scaffolds.2.fa',
        slice3='inputs/sylvestris/Olea_europaea_1kb_scaffolds.3.fa'
    conda: "envs/env.yml"
    shell:'''
    # compute tetranucleotide frequency of scaffolds
    sourmash compute -k 4 --scaled 1 --track-abundance --singleton --name-from-first -o {output.slice0} {input.slice0}
    sourmash compute -k 4 --scaled 1 --track-abundance --singleton --name-from-first -o {output.slice1} {input.slice1}
    sourmash compute -k 4 --scaled 1 --track-abundance --singleton --name-from-first -o {output.slice2} {input.slice2}
    sourmash compute -k 4 --scaled 1 --track-abundance --singleton --name-from-first -o {output.slice3} {input.slice3}
    '''

rule run_sourmash_compare_sylv_1kb:
    output: 
        slice0='outputs/sylvestris/Olea_europaea_1kb_scaffolds.0.comp',
        slice0label='outputs/sylvestris/Olea_europaea_1kb_scaffolds.0.comp.labels.txt',
        slice1='outputs/sylvestris/Olea_europaea_1kb_scaffolds.1.comp',
        slice1label='outputs/sylvestris/Olea_europaea_1kb_scaffolds.1.comp.labels.txt',
        slice2='outputs/sylvestris/Olea_europaea_1kb_scaffolds.2.comp',
        slice2label='outputs/sylvestris/Olea_europaea_1kb_scaffolds.2.comp.labels.txt',
        slice3='outputs/sylvestris/Olea_europaea_1kb_scaffolds.3.comp',
        slice3label='outputs/sylvestris/Olea_europaea_1kb_scaffolds.3.comp.labels.txt'
    input: 
        slice0='outputs/sylvestris/Olea_europaea_1kb_scaffolds.0.sig',
        slice1='outputs/sylvestris/Olea_europaea_1kb_scaffolds.1.sig',
        slice2='outputs/sylvestris/Olea_europaea_1kb_scaffolds.2.sig',
        slice3='outputs/sylvestris/Olea_europaea_1kb_scaffolds.3.sig'
    conda: "envs/env.yml"
    shell:'''
    sourmash compare -k 4 -o {output.slice0} {input.slice0} 
    sourmash compare -k 4 -o {output.slice1} {input.slice1}
    sourmash compare -k 4 -o {output.slice2} {input.slice2}
    sourmash compare -k 4 -o {output.slice3} {input.slice3}
    '''

rule suspicious_contigs_sylv:
    output: 
        file0='outputs/sylvestris/suspicious_contigs.txt'
    input: 
        comp0='outputs/sylvestris/Olea_europaea_1kb_scaffolds.0.comp',
        lab0='outputs/sylvestris/Olea_europaea_1kb_scaffolds.0.comp.labels.txt',
        comp1='outputs/sylvestris/Olea_europaea_1kb_scaffolds.1.comp',
        lab1='outputs/sylvestris/Olea_europaea_1kb_scaffolds.1.comp.labels.txt',
        comp2='outputs/sylvestris/Olea_europaea_1kb_scaffolds.2.comp',
        lab2='outputs/sylvestris/Olea_europaea_1kb_scaffolds.2.comp.labels.txt',
        comp3='outputs/sylvestris/Olea_europaea_1kb_scaffolds.3.comp',
        lab3='outputs/sylvestris/Olea_europaea_1kb_scaffolds.3.comp.labels.txt'
        
    run:
        import statistics
        
        # load numpy array into python
        comp0 = np.load(input.comp0)
        comp1 = np.load(input.comp1)
        comp2 = np.load(input.comp2)
        comp3 = np.load(input.comp3)
        
        # convert to a pandas dataframe
        df0 = pd.DataFrame(comp0)
        df1 = pd.DataFrame(comp1)
        df2 = pd.DataFrame(comp2)
        df3 = pd.DataFrame(comp3)
        
        # read labels into python
        f0 = open(input.lab0, 'r')
        labels0 = f0.readlines()
	
        f1 = open(input.lab1, 'r')
        labels1 = f1.readlines()
        
        f2 = open(input.lab2, 'r')
        labels2 = f2.readlines()
        
        f3 = open(input.lab3, 'r')
        labels3 = f3.readlines()
        
        # set column names to labels
        df0.columns = labels0
        df1.columns = labels1
        df2.columns = labels2
        df3.columns = labels3
	
        # calculate column means
        column_means0 = df0.mean(axis=1)
        column_means1 = df1.mean(axis=1)
        column_means2 = df2.mean(axis=1)
        column_means3 = df3.mean(axis=1)

        # calculate suspicion cutoff
        cutoff0 = statistics.mean(column_means0) - 2*(statistics.stdev(column_means0))
        cutoff1 = statistics.mean(column_means1) - 2*(statistics.stdev(column_means1))
        cutoff2 = statistics.mean(column_means2) - 2*(statistics.stdev(column_means2))
        cutoff3 = statistics.mean(column_means3) - 2*(statistics.stdev(column_means3))

        # grab suspicious columns
        suspicious_columns0 = df0.loc[:, df0.mean() < cutoff0]
        suspicious_columns1 = df1.loc[:, df1.mean() < cutoff1]
        suspicious_columns2 = df2.loc[:, df2.mean() < cutoff2]
        suspicious_columns3 = df3.loc[:, df3.mean() < cutoff3]
	    
        # write column names to list
        suspicious_column_names0 = suspicious_columns0.columns.tolist()
        suspicious_column_names1 = suspicious_columns1.columns.tolist()
        suspicious_column_names2 = suspicious_columns2.columns.tolist()
        suspicious_column_names3 = suspicious_columns3.columns.tolist()
        
        suspicious_column_names = suspicious_column_names0 + suspicious_column_names1 + suspicious_column_names2 + suspicious_column_names3
        
        # write suspicious labels to a file
        with open(output.file0, 'w') as file_handler:
            for item in suspicious_column_names:
                file_handler.write("{}".format(item))
