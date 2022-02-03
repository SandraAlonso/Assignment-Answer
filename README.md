# Assignment-Answer
Assignment Answer for Bioinformatic Programming Challenges subject

## Command for code excution:

### Frist assignment: 
      Running command: .\Main.rb gene_information.tsv seed_stock_data.tsv cross_data.tsv new_stock_file.tsv 
  
### Second assignment: 
In both approaches, it is mandatory to introduce the depth level. (it is asked when running)
#### First Approach
1.  Explanation:  
    Gene Networks are considered to be closed nets with its first and last gene from the Arabidopsis initial gene list.
    
    In example (1 level depth): Arabidopsis list: A, B, C, E. Iteractors of A with depth 1: D, E, C, J. Therefore, the are two nets A-C and A-E. Genes A and C are coexpressed 
    
    In example: (2 level depth) Arabidopsis list A, B, C, E. Interactors of B with depth 1: H, I, J. Intercators of H with depth 1: C, P. Therefore, there is one net: B-I-C. Genes B and C are coexpressed. 
    
    In addition, it has been considered (for 1 level depth in example) the next scenario:  Arabidopsis list: A, B, C, E. Iteractors of A with depth 1: D, E, C, J. Interactors of B with depth 1: H, I, J. Therefore, there is one net: A-J-B. So A and B are coexpressed.
          
        Running command: .\Main.rb 
#### Second Approach 
1. Explanation: 
    Gene Networks are considered to be every interactor whose have the same "father". In this case, we will only annotate those which are included in the Arabidopsis initial gene list 
    
    In example (1 level depth) Arabidopsis list: A, B, C, E. Iteractors of A with depth 1: D, E, C, J. Therefore, the is one net A-D-E-C-J and although they are all in the network, only A, C and E  will be annotated. Genes A, E and C are coexpressed
    
    In example: (2 level depth) Arabidopsis list A, B, C, E. Interactors of B with depth 1: H, I, J. Interactors of H with depth 1: C, P. Therefore, there is one net: B-H-I-J-C-P and although they are all in the network, we will only annotate B and C. Genes B and C are coexpressed.
    
        Running command: .\Main.rb
   
### Thrith assignment: 
    Running command: .\Main.rb (it is mandatory to introduce the repeat you want to find. It is asked when running) 

### Fourth assignment: 
    Running command: .\Main.rb TAIR10.fa pep.fa
    
### Fifth assignment:
Execute in UniProt SPARQL Endpoint: https://sparql.uniprot.org/sparql
