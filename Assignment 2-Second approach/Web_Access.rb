require 'rest-client'

class Web_Access

    def initialize
    end
    
  #Fetch function taken from classes notes
  # Create a function called "fetch" that we can re-use everywhere in our code
  def fetch(url, headers = {accept: "*/*"}, user = "", pass="")
        response = RestClient::Request.execute({
        method: :get,
        url: url.to_s,
        user: user,
        password: pass,
        headers: headers})
        return response
        
        rescue RestClient::ExceptionWithResponse => e
        $stderr.puts e.inspect
        response = false
        return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
        rescue RestClient::Exception => e
        $stderr.puts e.inspect
        response = false
        return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
        rescue Exception => e
        $stderr.puts e.inspect
        response = false
        return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
  end 

  def coexpressed(gene)
    gene = gene.id
        coexpressed_genes=[]
       
        #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
        # I have tried both dataBases (thinking about utoronto was better I started whit it)                                                                                                                #
        # But as I incremented the depth level, I realized that this dataBase contain much more medium to high-confidence interactions for each genes. This situation ends in a too long execution time.    #
        # Finally, I have run for 1 depth level in both datBases (see reports folder) and for deeper levels I have choosen ebi.ac.uk dataBase.                                                              #
        # DataBases links:                                                                                                                                                                                  #
        #       utoronto:  http://bar.utoronto.ca:9090/psicquic/webservices/current/search/query/#{gene}?format=tab25                                                                                       #
        #       ebi.ac.uk: http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/interactor/#{gene}?format=tab25                                                                #
        #                                                                                                                                                                                                   #
        # You can try both of them by changin line 48                                                                                                                                                       #
        #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

        res = fetch("http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/interactor/#{gene}?format=tab25")
        if res #if it is not an empty web page (there are some interactions)
            body = res.body  
            data = body.split("\n").to_a    #Separate interactions info into array
            data.each do |line|
                line = line.split("\t")     #As I have choosen the tab25 format, I have to separate the columns
                if line[9].include?("3702") && line[10].include?("3702")    #Taxonomy id of Arabidopsis Thaliana is 3701 (https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=3702)
                    score = line[14].split(":")[1]
                    if score.to_f > 0.4                                     #Generally speaking, scores > 0.4 correspond to medium to high-confidence interactions: (https://platform-docs.opentargets.org/target/molecular-interactions)
                        line = line[4..5]                                   #These columns of the tab25 format cointain the gene locus name so we need to scan and save it  
                        line.each do |k|
                            k.scan(/A[Tt]\d[Gg]\d\d\d\d\d/).each do|up|
                                up.upcase!
                                coexpressed_genes.push(up)                  #Saving the coexpressed gene in the array at upper-case
                            end
                        end
                    end
                    
                end
            end        
            coexpressed_genes=coexpressed_genes.flatten.uniq                #Avoiding repeated elements
            coexpressed_genes = coexpressed_genes-[gene]                    #We shouldn't include  the current gene because it cannot interacte with itself
        end    
        return coexpressed_genes
  end

  def prot_id_access(gene) #Look for the proteines of the current gene
    gene = gene.id    
    res = fetch("http://togows.org/entry/ebi-uniprot/#{gene}/accessions.json") #url address
        if res #if the page exists and have some info in it
            body = res.body  
            data = JSON.parse(res.body)[0]  #We need to parse the Json Format and take the first element of the result array.
            return data
        end
  end

  def kegg_access(gene)
    gene = gene.id
        res = fetch("http://togows.org/entry/kegg-genes/ath:#{gene}/pathways.json")
        kegg=[]
        if res #if the page exists and have some info in it
            body = res.body  # get the "body" of the response
            data = JSON.parse(res.body)[0]
            if !data.nil? 
                kegg = data.to_a
            end
        end
        return kegg
  end
  
  def go_access(gene)
    gene = gene.id
        res = fetch("http://togows.dbcls.jp/entry/uniprot/#{gene}/dr.json")
        go = []
        if res #if the page exists and have some info in it
            body = res.body 
            data = JSON.parse(res.body)[0]
            if !data["GO"].nil?
                data["GO"].each do |g| 
                    if g[1] =~ /^P:/    #We were asked to only include biological_process part of the GO Ontology and we know that bioloical process annotation starts with P(http://geneontology.org/docs/ontology-documentation/ or https://www.ebi.ac.uk/QuickGO/annotations)
                                        #and not molecular function or cellular component
                        go.push(g[0..1])
                    end
                end
            end           
        end
        return go
    end

end