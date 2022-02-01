class Gene

    attr_accessor :id
    attr_accessor :name
    attr_accessor :mutant_phenotype
    attr_accessor :linked_genes

    def initialize (params={})
        @id=params.fetch(:id, nil)
        if !gene_verification(@id)    #Gene verification by reg exp
            abort "ERROR: The Arabidopsis gene identifier #{@id} do not have the appropriate format"
        end
        @name=params.fetch(:name, nil)
        @mutant_phenotype=params.fetch(:mutant_phenotype, nil)
        @linked_genes = params.fetch(:linked_genes, nil)
    end

    def add_linked_genes(gene) #Addition of a new gene to the linked_genes attribute of the actual gene
        @linked_genes.append(gene)
    end

    def gene_verification(id)
        return id=~/A[Tt]\d[Gg]\d\d\d\d\d/ #Rg exp for Arabidopsis gene identifier
    end
    
end