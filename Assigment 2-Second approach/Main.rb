#Required classes
require 'rest-client'
require 'json' 
require './Network_Interaction'
require './Network_Genes'
require './Networks'


#Arguments introduced by the terminal
puts "Please, introduce the depth level. (Not recomended more than 3 levels)"
depth = gets

if depth.to_i<1 || !depth # If depth is missing then abort
    abort "Please introduce a positive depth level. \n\n"
end

#Read given file with gene list--------------------------------------------
gene_list_file = File.new("./ArabidopsisSubNetwork_GeneList.txt","r")

#Save in an array the hole file. (For not reading it every time)
genes=[]
genes2=[]
gene_list_file.each do |gene| 
    gene.upcase! #With ! we do not need to do gene = gene.upcase
    gene = gene[0..8] #This cut is because in the list it is included a "\n" behind each gene, so we only take the first 8 characters
    genes2.push(gene) #This array contains gene list names (ids)
    n_g = Network_Genes.new(:id=>gene) #We need to set all the genes in capital letters for looking for them at the web page.                      
    n_g.father= n_g #For the list genes, its father will be itself
    genes.push(n_g)
end
#Create networks-----------------------------------------------------------
new_net = Network_interaction.new(:genes => genes, :genes2=>genes2)
n=0
depth = depth[0].to_f-1
new_net.interactions(genes, n, depth)  #Look for all the interactions. genes is the gene initial list, n is the current depth and depth is the final depth


#Creating report-------------------------------------------------------------

networks = Networks.new()
networks.find_repeated_networks                                                       #We do not need every net. Some ofe them are included in other so we eliminate them
all_nets = networks.get_final_networks
network_file = File.open('./reports/networks_file_3_level_ebi_database.txt', "a+")    #I have used a+ mode to not overwrite the file and continue writting bellow
network_file.puts "Depth level:  #{depth+1}"                                          #Depth level
network_file.puts "The total number of network is #{all_nets.length}"                 #Final networks number

cont = 1
all_nets.each do |net|                                                                #Netork iteration to see every gen inside
    if net.list_genes.length>0
        network_file.puts "In network #{cont} are included #{net.list_genes.length} genes of the initial list"
        non_list_genes = []
        network_file.puts "\tNetwork #{cont}"                                         #Network number
        net.list_genes.each do |gene|                                                 #Genes which are coexpressed from the list and their info
            coex_ids=[]
            network_file.puts "\t\t *Gene id: #{gene.id}"                               
            network_file.puts "\t\t *Proteine id: #{gene.prot_id}"
            network_file.puts "\t\t *KEGG: #{gene.kegg}"
            network_file.puts "\t\t *GO: #{gene.go}"
            gene.coexpressed_genes.each do |id|                                        
                coex_ids.push(id.id)                                                   
            end
            network_file.puts "\t\t *Coexpressed genes: #{coex_ids}"
            network_file.puts "\n"
        end
        cont = cont +1
        network_file.puts "\t\t In addition, they are join by other genes which are not in the list. These are:"
        net.genes.each do |id|                                                        #I have not annotated genes which are not in the initial (took much time) list but it is posible just like on the lines before but for the gene list
            non_list_genes.push(id.id)                                                #I have only show their ids
        end
        non_list_genes.uniq!
        network_file.puts "\t\t #{non_list_genes}"
            network_file.puts "\n"
    end
end
