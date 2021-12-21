# Blas_function class implements all the function related to blast methods:
# 1. get_se_type(file) => finds out which type of sequence contains the file (Nucleic Acid sequence or Aino Acid sequence)
# 2. create_databases(file1, file2) => create blast database from files.
# 3. create_factories(org1, org2) => use create database to create factories to the organisims
class Blast_functions 

    def get_seq_type(organism)
        flat_file = Bio::FlatFile.auto(organism.file) 
        seq = Bio::Sequence.new(flat_file.next_entry.seq) 
                                                            # Result format: Bio::Sequence::NA or Bio::Sequence::AA
        seq_type = seq.guess.to_s.split('::')[-1]           # We only need the last part to know with seqType is: AA or NA
        if seq_type == 'NA'                                 # If it has been considered NA sequence type, then it is a Nucleic Acid sequence (http://bioruby.org/rdoc/Bio/Sequence/NA.html)
            organism.type='nucl'                            # Saving in the organism object its file type
            return 'nucl' 
        else 
            organism.type='prot'                            # Saving in the organism object its file type
            return 'prot'                                   # If it has been considered NA sequence type, then it is an Amino Acid sequence (http://bioruby.org/rdoc/Bio/Sequence/AA.html)
        end
    end


    # See user manual for ncbi-blast+: http://nebc.nerc.ac.uk/nebc_website_frozen/nebc.nerc.ac.uk/bioinformatics/documentation/blast+/user_manual.pdf
    def create_databases (organism)  
        # shell command: makeblastdb -in $input_file -dbtype $file_type(nucl,prot) -out $output_database_name
        # It can also be used a masking data (not necessary for this task)                   
        system("makeblastdb -in #{organism.file} -dbtype #{organism.type} -out ./Databases/#{organism.file}") # We ask for the file type to organism object
        # For a clean and entendible environment I have created a folder called Database for storing this created files
        # It is manadatory that the folder exists before the program starts.
    end


    def create_factories (organism1, organism2) # wherever your database is....a BLAST "factory" 
        if organism1.type == 'nucl' && organism2.type == 'nucl'                         # Counsult type at the organism object
            factory1 =  Bio::Blast.local('blastn', "./Databases/#{organism1.file}")     # Create a factory per database
            factory2 =  Bio::Blast.local('blastn', "./Databases/#{organism2.file}")
          
        elsif organism1.type == 'prot' && organism2.type == 'prot'                       # Counsult type at the organism object
            factory1 =  Bio::Blast.local('blastp', "./Databases/#{organism1.file}")      # Create a factory per database
            factory2 =  Bio::Blast.local('blastp', "./Databases/#{organism2.file}")
          
        elsif organism1.type == 'nucl' && organism2.type == 'prot'                       # Counsult type at the organism object
            factory1 =  Bio::Blast.local('tblastn', "./Databases/#{organism1.file}")     # Create a factory per database
            factory2 =  Bio::Blast.local('blastx', "./Databases/#{organism2.file}")
          
        elsif organism1.type == 'prot' && organism2.type == 'nucl'                       # Counsult type at the organism object
            factory1 =  Bio::Blast.local('blastx', "./Databases/#{organism1.file}")      # Create a factory per database
            factory2 =  Bio::Blast.local('tblastn', "./Databases/#{organism2.file}")
          
        end
        # Save the factory at each organism object
        organism1.factory=factory1  
        organism2.factory=factory2
    end

    def search_orthologs(organism1, organism2)
        orthologs = [] # Return parameter
        org1 = Hash.new
        org2 = Hash.new        
        
        Bio::FlatFile.auto(organism1.file).each_entry do |entry| # iterate over the sequences and save the information on the created hash map
            org1[entry.entry_id]=entry.seq              
        end
        
        Bio::FlatFile.auto(organism2.file).each_entry do |entry| # iterate over the sequences and save the information on the created hash map
            org2[entry.entry_id]=entry.seq             
        end
                
        org2.each do |entry|    # Iteration of the sequence in search
            query_org_2 = organism1.factory.query(">myseq\n#{entry[1]}")
            if query_org_2.hits.length != 0 && query_org_2.hits[0].evalue <= (10**-6) && ((query_org_2.hits[0].query_end.to_f-query_org_2.hits[0].query_start.to_f)/query_org_2.hits[0].query_len.to_f)>0.5     #Conditions for the hit to be considered a good one: e-value threshole = 10^⁻6 and coverage over 50%
                hit_id = query_org_2.hits[0].definition.split('|')[0].strip                                                     # Get id of the best hits       
                query_org_1 = organism2.factory.query(">myseq\n#{org1[hit_id]}")                                                # Do blast on the best hit sequence got on last step
                if query_org_1.hits.length != 0 && query_org_1.hits[0].evalue <= (10**-6) && ((query_org_1.hits[0].query_end.to_f-query_org_1.hits[0].query_start.to_f)/query_org_1.hits[0].query_len.to_f)>0.5  #Conditions for the hit to be considered a good one: e-value threshole = 10^⁻6 and overage over 50%
                    if query_org_1.hits[0].definition.split('|')[0].to_s.strip == entry[0]                                      # The best hit must have this format
                        orthologs.push([entry[0],hit_id])                                                                       # If everything is correct, we add them to the ortholog list
                        puts "#{entry[0]}----#{hit_id}"                                                                         # This outputs helped me to follow program iterations
                        puts "overlap = #{query_org_2.hits[0].overlap}, #{query_org_1.hits[0].overlap}"
                    end
                end
            end
        end
        return orthologs
    end
end