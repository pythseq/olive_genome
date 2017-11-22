num = ['00', '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50', '51']

rule install_blast_db:
    output: expand('nt.{n}.tar.gz', n = num)
    conda: "blast.yml"
    shell:'''
    	wget 'ftp://ftp.ncbi.nlm.nih.gov/blast/db/nt.*.tar.gz'
    	cat nt.*.tar.gz | tar -zxvi -f - -C .
    '''
   