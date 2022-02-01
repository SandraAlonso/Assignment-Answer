#Required classes
require 'rest-client'
require './Web_Access'
require './Network_Genes'

class Network_interaction
    attr_accessor :genes 
    attr_accessor :genes2 
    attr_accessor :networks 

    def initialize (params = {}) 
        @genes = params.fetch(:genes, nil) 
        @genes2 = params.fetch(:genes2, nil) 
        @networks = Hash.new

    end

    def look_for_gene(id) #This function is used to look if the current gene is in the intial Arabidopsis list
        # puts "loking for gene #{id}"
        if @genes2.include?(id)
            return true
        else
            return false
        end
    end

    def complete_gene_obj(gene) #completing every att of the gene
        w_a = Web_Access.new()
        gene.prot_id = w_a.prot_id_access(gene)
        gene.kegg = w_a.kegg_access(gene)
        gene.go = w_a.go_access(gene)
        if gene.coexpressed_genes.empty?
            coexpressed_genes = w_a.coexpressed(gene)
            coexpressed_genes.each do |gen| 
                obj_gen = Network_Genes.new(:id=>gen, :father=>gene)
                gene.coexpressed_genes.push(obj_gen) 
            end
        end
    end

    def check_net_exist(new_net) #Not sure if network A->B->C is the same as C->B->A. Just in case I have suppoised that are the same because at the end the are already coexpressed so I avoid duplicate networks. If it was not correct, just delet this function
        not_exist = true
        # networks["Network #{i}"][0].length == new_net.length &&
        (1..networks.length).each do |i|   
            if  networks["Network #{i}"][0].id==new_net[new_net.length-1].id && networks["Network #{i}"][networks["Network #{i}"].length-1].id==new_net[0].id #cheking if the first and last element of the current net is already one of the previous net.
                not_exist = false
                break
            end
        end
        return not_exist
    end

    def check_loop(new_net)
       if new_net[0].id == new_net[new_net.length-1].id
        return false
       else
        return true
       end
    end

    def create_network(gene) #Once we have found by the recusrive unction a gen which was in the intial list, we can now close the network
        net = []
        while !gene.father.nil? #We need to folloe the father path until one of the father is nil. This will mean that this gene is also one of the genes included in the initial list
            complete_gene_obj(gene)
            net.push(gene)
            gene = gene.father
        end
        net.push(gene) #We need to also include the first father of the net (the first gene)
        complete_gene_obj(gene)
        new_net = Hash.new
        if net.length > 1 && check_net_exist(net) && check_loop(net)
            puts "Gen found, closing network #{networks.length+1}"
            net.each do |g|
                print "#{g.id}, "
            end
            print"\n"
            new_net = { "Network #{networks.length+1}" => net } #Creation of anew network with key name: "Network x" and all the genes mentioned before
            # puts networks.length
            networks.merge!(new_net)#I have merge the original networks Hash (with all the previous nets) amd the current network
            # puts networks.length
        end
    end

 #---------------------RECURSIVE FUNCTION---------------------------

 # A recursive function is a function that calls itself during its execution. 
 # The process may repeat several times, outputting the result and the end of each iteration.

    def interactions(gene_list, n, depth)
        array_net=[]
        w_a = Web_Access.new()
        gene_list.each do |gene| #The first list which is given is the ArabidopsisSubNetwork:GeneList.txt. Then, it will be the coexpressed genes of each gene on the list and so on.
                puts "initial coexpressed of #{gene.id}"
                coexpressed_genes = w_a.coexpressed(gene) #Looking for the coeexpressed genes of the current gen
                puts coexpressed_genes.length

                coexpressed_genes.each do |gen| #Once we got the coexpressed genes array, we construct the object to make it easier to access them
                    obj_gen = Network_Genes.new(:id=>gen, :father=>gene) #I have filled two fields, id and father.
                    gene.coexpressed_genes.push(obj_gen) #genes are added to the father gene coexpressed list
                    if look_for_gene(obj_gen.id) #First condition to end the recursive function: if we have found a gen from the first list (ArabidopsisSubNetwork:GeneList.txt) in the current iteration we must stop the search and create a network
                        #puts obj_gen.id.upcase!
                        create_network(obj_gen)        #In addition, with this decission we can avoid inifinite loops
                    end
                end    
                if  !gene.coexpressed_genes.empty? && n < depth #here we can modify the depth level. I have chosen 3 because is the higher level that my laptop could put up with
                    # puts "looking for coex of gene #{gene.id}"
                    interactions(gene.coexpressed_genes, n+1, depth) #recursive call with the current gene coexpressed genes list. We need to increment n in 1 to increase the depth level
                end
                 
        end
    end
#----------------------------------------------------------------

end