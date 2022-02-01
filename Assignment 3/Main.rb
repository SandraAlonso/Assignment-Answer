require './Gff_writer'
require './Sequence.rb'

#Arguments introduced by the terminal
puts "Please, introduce the repetition you want to look for"
repeat = gets

if !repeat.to_s # If repeat is missing then abort
    abort "Please introduce a string as repetition. \n\n"
end
repeat.chomp! #get only the string without /n

#Read given file with gene list
gene_list_file = File.new("./ArabidopsisSubNetwork_GeneList.txt","r")

#Save in an array the hole file. (For not reading it every time)
genes=[]
gene_list_file.each do |gene| 
    gene.upcase!                #With ! we do not need to do gene = gene.upcase
    gene = gene[0..8]           #This cut is because in the list it is included a "\n" behind each gene, so we only take the first 8 characters
    genes.push(gene)            #This array contains gene list names (ids)
end

sequence = Sequence.new(:repeat_string=>repeat) #Creating a sequence object with the target repeat
included_genes = []                             #Final genes with the target repeat
genes.each do |g|
    if sequence.search_gene(g)                  #If the repeat was found
        included_genes.push(g)                  #Add gene id to the array
    end
end

non_included_genes_file = File.open('./reports/non_included_genes.txt', "a+")                           #Create report file
non_included_genes_file.puts "--------------------REPORT-------------------------" 
non_included_genes_file.puts "Initial Arabidopsis gene list size #{genes.length}"                       #Include the initial number of genes
non_included_genes_file.puts "Final number of genes with '#{repeat}' repeat #{included_genes.length}"   #Include the target repeat and genes with this repeat
non_included_genes_file.puts "Genes without exons with the '#{repeat}' repeat: #{genes-included_genes}" #Include gene ids without the repeat

all_gff = Gff_writer.new()          #Writte the gff3 file
all_gff.write_gff                   #For exercise 4a
all_gff.write_gff_ensembl_coords    #For exercise 5