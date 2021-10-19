require './DataBase'

#Arguments introduced by the terminal
genefile, seedstockfile, hybridcrossfile, newstockfile = ARGV

#Validation of the number of arguments. Must be 4
if !genefile || !seedstockfile || !hybridcrossfile || !newstockfile # If some file is missing then abort
    abort "Arguments are not enough. You should use Main.rb genefile seedstockfile hybridcrossfile newfile\n\n"
end

#I have created a folder with all the files to obtain a cleaner environment so we need to use the path: ./StockDatabaseDataFiles/ + file_name
d = DataBase.new(
    :genefile => './StockDatabaseDataFiles/'+genefile,
    :seedstockfile =>  './StockDatabaseDataFiles/'+seedstockfile,
    :hybridcrossfile => './StockDatabaseDataFiles/'+hybridcrossfile,
    :newstockfile => './StockDatabaseDataFiles/'+newstockfile
)

#Create database by loading all the files
d.load_files()

#Simulate planting 7 grams of seeds from each of the records in the seed stock genebank.
d.seed_stock_db.each do |s| #s has to elems, the id we have selected (geneid) and all the information related to the gen.
                            #for iterating, we just need to look at the s[1] element (object information) because we just want to modify one attribute of the object
    s[1].plant_Seeds() 
end

#Look for genetically-linked genes
d.hybrid_cross_db.each do |h|
    h.chi_square()              #calculate chi-square for every object included in cross_data file
end

#Print genetically-linked genes
puts
puts "Final Report"
d.genes_db.each do |g| # As I have include an attribute called linked_genes in each gene we know which ones al linked
    if !g[1].linked_genes.empty? # If array is not empty, the gene has other linked genes
        g[1].linked_genes.each do |linked| # We iterate the hole array just in case there are more than one        
            puts "#{g[1].name} is linked to #{linked.name}"
        end
    end
end

#Update stock info in a new file
d.write_new_stock_file('./StockDatabaseDataFiles/'+newstockfile)


puts

#demonstrations of the functions for bonus
puts "-------------BONUS-------------"
puts "1. Verify gene identifier format"
# +1% if your Gene Object tests the format of the Gene Identifier and rejects incorrect formats without crashing
# I have created a file with a wrong gem format: ATp1G69120 in ./BonusFile/gene_information.tsv
d = DataBase.new(
    :genefile => './BonusFiles/'+genefile,
    :seedstockfile =>  './StockDatabaseDataFiles/'+seedstockfile,
    :hybridcrossfile => './StockDatabaseDataFiles/'+hybridcrossfile,
    :newstockfile => './StockDatabaseDataFiles/'+newstockfile
)
d.load_files()
# expected output: ERROR: The Arabidopsis gene identifier ATp1G69120 do not have the appropriate format

#1% if you create an Object that represents your entire Seed Stock "database"
#Here I have created DataBase.rb wich works as the database. 
#There are 3 functions to load all files and other one to write a new file with the updated stock
#This exercise is domonstrated throw the normal execution.