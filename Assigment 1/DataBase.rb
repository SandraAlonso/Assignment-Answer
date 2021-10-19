require './SeedStock'
require './HybridCross'
require './Gene'

#For obtaining a "dataBase" we need to store all the information in a tidy way
#DataBases usually use tables but in programmation field we will use Hashes

class DataBase
    attr_accessor :genes_db
    attr_accessor :seed_stock_db
    attr_accessor :hybrid_cross_db
    attr_accessor :header
    attr_accessor :newstockfile

    def initialize(params = {})
        @hybrid_cross_db = []      #hybridcrossfile info
        @seed_stock_db = Hash.new  #seedstockfile info
        @genes_db = Hash.new       #genefile info
        #Both Hashes will have this format: {id, object_info}
        #As hybridcrossfile do not have an uniq id, I have created an array

        @genefile = params.fetch(:genefile)
        @seedstockfile = params.fetch(:seedstockfile)
        @hybridcrossfile = params.fetch(:hybridcrossfile)
        @newstockfile = params.fetch(:newstockfile)

        validate_files(@genefile, @seedstockfile, @hybridcrossfile, @newstockfile)
    end

    def validate_files(genefile, seedstockfile, hybridcrossfile, newstockfile) #It is important to validate file extenssions
        unless genefile=~/.tsv$/ && seedstockfile=~/.tsv$/ && hybridcrossfile=~/.tsv$/ && newstockfile=~/.tsv$/
            abort "Some argument(s) are not .tsv files. Please try again with the proposed format (.tsv)"  #If there are any error it will abort
         end
     end

    def load_files()
        save_gene(@genefile)
        save_seed_stock(@seedstockfile)
        save_hybrid_stock(@hybridcrossfile)
    end

    
    def save_seed_stock(seedstockfile)
            seedstockfile = File.open(seedstockfile, 'r') do |f1|
                @header = f1.gets #headers   I need to store this header for updating the newfile later
                while line = f1.gets
                    data = line.strip.split("\t")               #Spliting the tsv file which is join by tabs
                    g = genes_db[data[1]]
                    s = SeedStock.new(:seed_stock =>data[0],    #Creating the object by the created array
                        :mutant_gene_id=>g, 
                        :last_planted=>data[2], 
                        :storage=>data[3], 
                        :grams_remaining=>data[4]
                    )
                    @seed_stock_db[data[0]] = s                #Adding a new SeedStock object to the Hash with the seed_stock_id
                end
            end
        end

        def save_gene(genefile)
            genefile = File.open(genefile, 'r') do |f1|
                f1.gets #headers
                while line = f1.gets
                    data = line.strip.split("\t")               #Spliting the tsv file which is join by tabs
                    g = Gene.new(:id =>data[0],                  #Creating the object by the created array
                        :name=>data[1], 
                        :mutant_phenotype=>data[2],
                        :linked_genes=>[]
                    )
                    @genes_db[data[0]] = g                     #Adding a new SeedStock object to the Hash with the gene_id
                end
            end
        end

        def save_hybrid_stock(hybridcrossfile)
            hybridcrossfile = File.open(hybridcrossfile, 'r') do |f1|
                f1.gets #headers
                while line = f1.gets
                    data = line.strip.split("\t")                               #Spliting the tsv file which is join by tabs
                    g1 = seed_stock_db[data[0]].mutant_gene_id      
                    g2 = seed_stock_db[data[1]].mutant_gene_id                  #hybridcrossfile contains two genes. Therefore I added them to the HybridCross Object. 
                                                                                #First I look for them in seed_stock_db by its id (hybridcrossfile)
                                                                                #Then I take the mutant_gene_id from this object
                    h= HybridCross.new(:parent1 =>g1,                           #Creating the object by the created array and the genes
                        :parent2=>g2, 
                        :f2_wild=>data[2], 
                        :f2_p1=>data[3], 
                        :f2_p2=>data[4], 
                        :f2_p1p2=>data[5],
                    )
                    @hybrid_cross_db.append(h)                                  #Adding a new SeedStock object to the array
                end
            end
        end

        def write_new_stock_file(newstockfile)
            newstockfile = File.new(newstockfile, "w")        #Create a new file
            File.open(newstockfile, 'w') do |f2|
                    f2.write(@header)                         #seedstockfile header
                    @seed_stock_db.each do |s|                #Print every object from the seedstockfile joined by tab
                        f2.write(s[1].seed_stock)
                        f2.write("\t")
                        f2.write( s[1].mutant_gene_id.id)
                        f2.write("\t")
                        f2.write(s[1].last_planted) 
                        f2.write("\t")
                        f2.write(s[1].storage)
                        f2.write("\t")
                        f2.write(s[1].grams_remaining) 
                        f2.write("\n")                      # create next line at new file
                    end
                end
            newstockfile.close     #It is important to close the file
        end
end