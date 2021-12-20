require 'bio'
require 'stringio'
require './Blast_functions'
require './Organism'

#-----Reading arguments--------------------
file1 = ARGV[0] 
file2 = ARGV[1] 

#-----Creating organism object-------------
organism1 = Organisim.new(:name => file1)
organism2 = Organisim.new(:name => file2)

blast = Blast_functions.new()

#-----Setting organism file type-----------
blast.get_seq_type(organism1)
blast.get_seq_type(organism2)

#-----Creating databases-------------------
blast.create_databases(organism1)
blast.create_databases(organism2)

#-----Creating factories-------------------
blast.create_factories(organism1, organism2)

#-----Searching for orthologs databases----
result = blast.search_orthologs(organism1,organism2)
    
#-----Creating the report-------------------
cont = 1
report_file = File.open('./reports/orthologs.txt', "a+")
report_file.puts "Number of sequences identified as orthologs:  #{result.length}."
report_file.puts "\nUsed files: #{file1.to_s.chomp('.fa')} and #{file2.to_s.chomp('.fa')} "
result.each do |ort|
  report_file.puts "#{cont}: #{ort[0]} and #{ort[1]}"
  cont=cont+1
end

#-----References-----------------------------
#
# https://academic.oup.com/bioinformatics/article/24/3/319/252715
#
# maximum E-value threshold of 1×10 − 6
# also required coverage of at least 50% of any of the protein sequences in the alignments.

#-----Bonus 1%--------------------------------
# Reciprocal-best-BLAST is only the first step in demonstrating that two genes are orthologous.
# Write a few sentences describing how you would continue to analyze the putative orthologues you 
# just discovered, to prove that they really are orthologues. You DO NOT need to write the code - 
# just describe in words what that code would do.

# Traditionally, classification of orthology is done through either a reciprocal best hit or 
# reciprocal smallest distance method. The basic procedure entails collecting all the genes in 
# two species and comparing them all to one another. If genes from two species identify each other as 
# their closest partners then they are considered orthologs. 

# Genome analysis, once they have been completelys equenced, could be done at two levels:
#   1. Structural analysis: aims to make a basic description of the elements that make up the genome and how they are organized. (Not necessary at all in our case)
#   2. Functional analysis: defines the function of each of the genes in a genome and the proteins they encode, and is one of the most 
#      important parts of the genome annotation process. 
#      We consider four types of methods to predict the function of a gene or its gene product:
#
#      a. Methods based on homology detection => BLAST
#      b. Methods based on comparison of genomes => They are used to predict interactions between proteins, but depending on the method, 
#         said interaction may correspond to a physical or functional interaction. In either case, it is assumed that two interacting proteins 
#         are part of the same cellular process.
#      c. Methods based on the analysis of protein sequences => they focus on the prediction of characteristics of predicted protein products
#      d. Methods based on the structure of proteins => they are based on the detection of active sites and the prediction of ligands

# Every method mentioned before (b to d) could be used in order to confirm an ortholog. IN my opinion, I would start with methods based on comparison of genomes
# becuase it seems to be the most accurate and easy to develop.

#-----------References:--------------------------
# https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2732758/
# http://www.pdg.cnb.uam.es/cursos/Leon_2003/pages/Genomas_Anal_Anot/2_2_Anal.html