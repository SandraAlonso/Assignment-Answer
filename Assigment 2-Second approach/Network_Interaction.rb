#Required classes
require 'rest-client'
require './Web_Access'
require './Network_Genes'
require './Networks'

class Network_interaction
    attr_accessor :genes 
    attr_accessor :genes2 
    attr_accessor :networks 

    def initialize (params = {}) 
        @genes = params.fetch(:genes, nil)      #Array with gene_objects
        @genes2 = params.fetch(:genes2, nil)    #Array of string with gene names
        @networks = Hash.new

    end

    def complete_gene_obj(gene) #completing every attributes of the gene
        w_a = Web_Access.new()
        gene.prot_id = w_a.prot_id_access(gene)
        gene.kegg = w_a.kegg_access(gene)
        gene.go = w_a.go_access(gene)
        complete_coexp(gene)
    end
    def complete_coexp (gene) #Completing the attribute coexpressed genes in case it has not been setted
        w_a = Web_Access.new()
        if gene.coexpressed_genes.empty?
            coexpressed_genes = w_a.coexpressed(gene)
            coexpressed_genes.each do |gen| 
                obj_gen = Network_Genes.new(:id=>gen, :father=>gene)
                gene.coexpressed_genes.push(obj_gen) 
            end
        end
    end

    def create_network(gene_list) #Creating a network from a gene_obj list
        n = Networks.new()
        genes =[]
        if !n.find_network(gene_list[0].father.id)              #If networks is not already created. Each network is represented by its father name (gene of the initial Arabidopsis list)
            genes_at_list=[]
            names = []
            puts "creating net of #{gene_list[0].father.id}"
            gene_list.each do |gene|
                complete_coexp(gene)                            #For each gene we complete its coexpressed (for instance only coexpressed because if they are not included inthe initial Arabidopsis list, we wont annotate all its information to save time)
                genes.push(gene)                                #I have added to a list which will be added to the future network
                if @genes2.include?(gene.id)                    #In case the current gene is included on the initial Arabidopsis list,
                    complete_gene_obj(gene)                     #We need to complete all its attributes (becuase this will be annotated in the report)
                    genes_at_list.push(gene)                    #We include them in the gene_list array of the net
                    names.push(gene.id)                         #We include its name on the name list
                end

            end
            if !genes_at_list.empty?                            #If the net is just conformed by genes which are not included in the list, we do not annotate them
                complete_gene_obj(gene_list[0].father)          #In case there is at least one, we complete and include the father of the net
                genes.push(gene_list[0].father)
                genes_at_list.push(gene_list[0].father)
                names.push(gene_list[0].father.id)

                new_net = Networks.new(:name => gene_list[0].father.id, :genes => genes, :list_genes=>genes_at_list, :list_genes_names=>names) #Creation of the net
            end

        else                                                    #In case the net already exists (have some of the list genes inside)
            net = n.get_network(gene_list[0].father.id)
            gene_list.each do |gene|                            #We add the hole list to it
                complete_coexp(gene)                            #Firstly completing the genes
                net.genes = net.genes.push(gene)                #And then adding them
                if(@genes2.include?(gene.id))                   #In case they are included on the Arabiopsis list
                    complete_gene_obj(gene)                     #We complete all its attributes
                    net.list_genes = net.list_genes.push(gene)  #And add them to both lists
                    net.list_genes_names = net.list_genes_names.push(gene.id)
                end

            end
        end
    end

 #---------------------RECURSIVE FUNCTION---------------------------

 # A recursive function is a function that calls itself during its execution. 
 # The process may repeat several times, outputting the result and the end of each iteration.

    def interactions(gene_list, n, depth)
        array_net=[]
        w_a = Web_Access.new()
        gene_list.each do |gene| #The first list which is given is the ArabidopsisSubNetwork:GeneList.txt. Then, it will be the coexpressed genes of each gene on the list and so on.
                coexpressed_genes = w_a.coexpressed(gene) #Looking for the coeexpressed genes of the current gen 
                puts "initial coexpressed of #{gene.id} are #{coexpressed_genes.length}"

                coexpressed_genes.each do |gen| #Once we got the coexpressed genes array, we construct the object to make it easier to access them
                    if gen != gene.father.id #Avoiding loops. If current gen id is the same as the fathers id, they are the same and therefore they have started a loop
                        obj_gen = Network_Genes.new(:id=>gen, :father=>gene.father) #I have filled two fields, id and father.
                        gene.coexpressed_genes.push(obj_gen) #genes are added to the father gene coexpressed list
                    end
                end    

                if  n < depth #This is the exit condition, the maximum depth level
                    interactions(gene.coexpressed_genes, n+1, depth) #recursive call with the current gene coexpressed genes list. We need to increment n in 1 to increase the depth level
                end
                if !gene.coexpressed_genes.empty?
                    create_network(gene.coexpressed_genes) #In case there are noot more levels, we start the creation of the network
                end
                 
        end
    end
    
#----------------------------------------------------------------

end