class Exon

    attr_accessor :coords
    attr_accessor :strand
    attr_accessor :gene
    attr_accessor :bioseq

    def initialize (params = {})
        @gene = params.fetch(:gene, nil)        #gene to which the exon belongs
        @coords = params.fetch(:coords, [])     #coordinates where match is find
        @strand = params.fetch(:strand, nil)    #strand in which exon has been read
        @bioseq = params.fetch(:bioseq, nil)    #sequence of the exon
    end
    
end