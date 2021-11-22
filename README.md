# Assignment-Answer
Assignment Answer for Bioinformatic Programming Challenges subject

Command for code excution:
<ul> 
  <li> Frist Assigmnet: 
     <ul> <li> Running command: .\Main.rb gene_information.tsv seed_stock_data.tsv cross_data.tsv new_stock_file.tsv </li>
  </ul>
  </li>
  <li> Second Assigment: In both approaches, it is mandatory to introduce the depth level. (it is asked when running)
  <ul> 
    <li> First Approach
      <ul> 
        <li> Explation:  
          <ul> <li> Gene Networks are considered to be closed nets with its first and last gene from the Arabidopsis initial gene list.</li>
            <li> In example (1 level depth): Arabidopsis list: A, B, C, E. Iteractors of A with depth 1: D, E, C, J. Therefore, the are two nets A-C and A-E. Genes A and C are coexpressed </li>
            <li> In example: (2 level depth) Arabidopsis list A, B, C, E. Interactors of B with depth 1: H, I, J. Intercators of H with depth 1: C, P. Therefore, there is one net: B-I-C. Genes B and C are coexpressed. </li>
            <li> In addition, it has been considered (for 1 level depth in example) the next scenario:  Arabidopsis list: A, B, C, E. Iteractors of A with depth 1: D, E, C, J. Interactors of B with depth 1: H, I, J. Therefore, there is one net: A-J-B. So A and B are coexpressed.
          </ul>
        </li>
        <li> Running command: .\Main.rb </li>
      </ul>
      </li>
    <li> Second Approach 
         <ul> 
           <li>Explanation:  </li>
           <li> Running command: .\Main.rb </li>
      </ul>
      </li>
  </ul>
     </li>
 </ul>
