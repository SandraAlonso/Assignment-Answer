class Gff_writer

    attr_accessor :input
    attr_accessor :entry
    @@all_gff = []

  def initialize (params = {})
        @input = params.fetch(:input, nil)      #Contains new features
        @entry = params.fetch(:entry, nil)      #Contains the rest of the info
       if !@input.nil?                          #Array with every gff entries
            @@all_gff << self
       end
    end

    def write_gff 
            report = File.open("./reports/ex4a.gff3", "a+")         #Creation of the gff file  
            report.puts "##gff-version 3"                           #Mandatory for the format
            @@all_gff.each do |gff|                                 #For each gff object
            gff.input.features.each do |feature|                    #Iterate over the features  
                if feature.feature == "searched_repeat"             #Until we find our new-created feature (searched_repeat)                    
                    feature.assoc["coords"].each do |c|             #As we hace added as feature its cordinates, we itereate all of them
                        start = c[0]                                #start coordinate
                        ending = c[1]                               #end coordinate
                        report.puts "#{feature.assoc['gene_ID'].downcase}\t#{feature.assoc['source']}\ttandem_repeat\t#{start}\t#{ending}\t·\t#{feature.assoc['strand']}\t·\tID=#{feature.assoc['gene_ID'].downcase};Species=#{gff.entry.species.delete(' ')};Repeat=#{feature.assoc['repeat_motif']}"  
                        #format for gff file (betwwen columns with tabs and dots) https://m.ensembl.org/info/website/upload/gff.html
                    end
                end
            end
        end    end

    def write_gff_ensembl_coords
        report = File.open("./reports/ex5.gff3", "a+")          #Creation of the gff file  
        report.puts "##gff-version 3"                           #Mandatory for the format
        @@all_gff.each do |gff|                                 #For each gff object
        gff.input.features.each do |feature|                    #Iterate over the features  
            if feature.feature == "searched_repeat"             #Until we find our new-created feature (searched_repeat)                    
                feature.assoc["coords"].each do |c|             #As we hace added as feature its cordinates, we itereate all of them
                    chr = gff.entry.accession.split(':')[2]     #Chromosome format
                    gene_start=gff.entry.accession.to_s.split(':')[3].to_i  #chromosome coordinates inside of the gene
                    start = c[0] + gene_start - 1               #start coordinate
                    ending = c[1] + gene_start - 1              #end coordinate
                    report.puts "chr#{chr}\t#{feature.assoc['source']}\ttandem_repeat\t#{start}\t#{ending}\t·\t#{feature.assoc['strand']}\t·\t ID=#{feature.assoc['gene_ID']};Species=#{gff.entry.species.delete(' ')};Repeat=#{feature.assoc['repeat_motif']}"  
                    #format for gff file (betwwen columns with tabs and dots) https://m.ensembl.org/info/website/upload/gff.html
                end
            end
        end
    end
end
end