require 'rest-client'
require './Gff_writer'
require './Exon'
require 'bio'

class Sequence

    attr_accessor :repeat
    attr_accessor :repeat_string
    attr_accessor :reg_exp
    attr_accessor :complement_reg_exp

    def initialize (params = {})
        @repeat_string = params.fetch(:repeat_string, nil)                          #Personalize the repetition string
        if !repeat_string.nil?
            @repeat = Bio::Sequence::NA.new(@repeat_string)                         #Create de biosequence for the repetition
            @reg_exp  = Regexp.new(@repeat.to_re)                                   #Create the regular expression for the repeat
            @complement_reg_exp = Regexp.new(@repeat.reverse_complement.to_re)      #Create the complement regular expression for the other side of the chain
        end
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

    
    def web_access (gene) #Obtaining gene information for the current gene (gene id)
        res = fetch("http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{gene}")  
        if res                  #If web is found and it is not empty
            body = res.body                                            
            File.open("./reports/gene_info.embl", 'w') do |myfile|  #We need to store web information for accessing its features (embl format)
                myfile.puts body
            end
            return true
        else
            return false
        end
    end

    def create_feature (exon_repeats)                                                #Create a new feature for the current gene exons
         exon_repeats.each do |rep|                                                  #Iterate over every exon which contains a repetition
            f = Bio::Feature.new('searched_repeat',rep)                              #Name of our new feature (searched_repeat), and all its qualifiers
            f.append(Bio::Feature::Qualifier.new('repeat_motif', repeat_string))     #Repetition characters which where looking for
            f.append(Bio::Feature::Qualifier.new('source', "assigment3"))            #Name of the program that generated this feature, or the data source (assigment 3)
            f.append(Bio::Feature::Qualifier.new('coords', rep.coords))              #Coords where it has been found
            f.append(Bio::Feature::Qualifier.new('gene_ID', rep.gene))               #Gene which contains the exon and the repetition
            f.append(Bio::Feature::Qualifier.new('strand', rep.strand))              #Positive or negative strand where it is found
            rep.bioseq.features << f                                                 #Add to the biosequence of the exon            
        end
    end
    
    def get_coords(target, seq, origin) #Obtain the coordinates where a match of the repeat is found
        coords=[]                               #Array to storage the matched positions
        origin=origin.to_i                      #Origin of the exon
        seq = seq.to_s                          #Sequence of the exon
        match = seq.enum_for(:scan, /(?=(#{target}))/).map { Regexp.last_match.begin(0) } #Mandatory for obtaining overlaping matches
        match.each do |m|                       #For each match
          starts = origin + m                   #Obtain the start of the match
          ends = starts - 1 + @repeat.length    #Obtain the end of the match
          coords.push([starts,ends])            #Add to the matched position array
        end
        return coords
    end

    def search_gene (gene)      #Look through the gene for its exons
        puts gene
        final_repeat_coords =[] #Array to store coordinates where the repear is found (non repeated)
        included = false        #Boolean used to know if the current gen contains the repeat (if not it will be included on the non_included_genes.txt)
        if web_access(gene)     #Successful web answer
            embl_file = Bio::FlatFile.auto("./reports/gene_info.embl")      #Creation of an embl file from web data to manage gene information
            embl_file.each_entry do |entry|                                 #For each line or entry of the embl file                 
                sequence = entry.to_biosequence                             #One of the file lines is SQ or sequence, we need to save it for looking for the repeat
                exon_repeats = []                                           #Parts of the exon where a repeat is found
                entry.features.each do |feature|                            #Embl file contains different lines, most ofthem are FT or features. we need to iterate them to obtain gene information
                    if feature.assoc['note'].to_s.include?('exon') &&  !feature.position.to_s.include?(':')      #For finding exon information we need to look for the feature "note" and be sure that it is refering of an "exon"                        
                        exon_position = feature.position.to_s.scan(/\d*\.\.\d*/)[0].split('..')                  #Exon format seems to be (x..xxxx), so we split it in order to obtain coordinates
                        exon_sequence = sequence[exon_position[0].to_i..exon_position[1].to_i]                   #Between this coords we copy the referenced part of the gene sequence

                        if feature.position.to_s.include?('complement')             #Exon is in the complement chain (strand = -)
                            coords = get_coords(@complement_reg_exp, exon_sequence, exon_position[0]) #Obtain the exon coordinates were there is a repeat through the regular expression and the first position of the exon
                            new_coords = coords-final_repeat_coords                 #As we do not need repeated coordinates, we eliminate the ones that have been already included in the final coords
                            if !new_coords.empty?                                   #If there is a new coord
                                new_coords.each do |c|
                                    final_repeat_coords.push(c)                     #We add them to the final array of coords
                                end
                                exon = Exon.new(:gene => gene, :coords=> new_coords, :strand=>'-', :bioseq=> sequence)   #And we add to the corrent exon object
                                exon_repeats.push(exon)                             #This exon is added to exon_repeats array to include it in the final gff file
                            end
                        else                                                        #Exon is in the positive chain (strand = +)
                            exon_start = exon_position[0].to_i + 1                  #IMPORTANT! It is mandatory to move one place doe to the displacement of the chain
                            coords = get_coords(@reg_exp, exon_sequence, exon_start) #Obtain the exon coordinates were there is a repeat through the regular expression and the first position of the exon
                            new_coords = coords-final_repeat_coords                 #As we do not need repeated coordinates, we eliminate the ones that have been already included in the final coords
                            if !new_coords.empty?                                   #If there is a new coord
                                new_coords.each do |c|
                                    final_repeat_coords.push(c)                     #We add them to the final array of coords
                                end
                                exon = Exon.new(:gene => gene, :coords=>new_coords, :strand=>'+', :bioseq=> sequence) #And we add to the corrent exon object
                                exon_repeats.push(exon)                             #This exon is added to exon_repeats array to include it in the final gff file
                            end
                        end
                    end
                end
                if !exon_repeats.empty?                                       #If there is any exon with repeat, a new feature is created, the gen contains the repeat and we add its exons to the gff file
                    create_feature(exon_repeats)                                 #We create a new feature in it
                    gff = Gff_writer.new(:input => exon_repeats[0].bioseq, :entry => entry) #New gff object is created for writing thn in the file
                    included = true
                end                   
            end
        else
            puts "Sorry, we could not find the gene in the data base."
        end
        return included #Return if the current gene has any repeat
    end    

end
  