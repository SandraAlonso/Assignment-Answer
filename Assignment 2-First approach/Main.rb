#Required classes
require 'rest-client'
require 'json' 
require './Network_Interaction'
require './Network_Genes'

#Arguments introduced by the terminal
puts "Please, introduce the depth level. (Not recomended more than 3 levels)"
depth = gets

#Validation of the number of arguments. Must be 4
if depth.to_i<1 || !depth # If depth is missing then abort
    abort "Please introduce a positive depth level. \n\n"
end

#Read given file with gene list--------------------------------------------
gene_list_file = File.new("./ArabidopsisSubNetwork_GeneList.txt","r")

#Save in an array the hole file. (For not reading it every time)
genes=[]
genes2=[]
gene_list_file.each do |gene| 
    gene = gene.upcase!
    gene = gene[0..8] #This cut is because in the list it is included a "\n" behinf each gene, so we only take the first 8 characters
    genes2.push(gene)
    n_g = Network_Genes.new(:id=>gene) #We need to set all the genes in capital letters for looking for them at the web page.
                                               #With ! we do not need to do gene = gene.upcase
    genes.push(n_g)
end
puts "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
#Create networks-----------------------------------------------------------
puts "gene 2 = #{genes2}"
new_net = Network_interaction.new(:genes => genes, :genes2=>genes2)
n=0
depth = depth[0].to_f-1
new_net.interactions(genes, n, depth)  #Look for all the interactions


#Creating report-------------------------------------------------------------
coex_ids=[]
network_file = File.open('./reports/networks_file_2_level.txt', "a+")                             #I have used a+ mode to not overwrite the file and continue writting bellow
network_file.puts "Depth level:  #{depth+1}"    #Final networks number
network_file.puts "The total number of network is #{new_net.networks.length}"    #Final networks number
n_genes=0
(1..new_net.networks.length).each do |i|   
    n_genes += new_net.networks["Network #{i}"].length                             #Number of genes included in the final networks
end
network_file.puts "The total number of genes is #{n_genes}"                        #Final genes number inside networks
(1..new_net.networks.length).each do |i|                                           #Netork iteration to see every gen inside
    network_file.puts "\tNetwork #{i}"
    new_net.networks["Network #{i}"].each do |gene|
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
end