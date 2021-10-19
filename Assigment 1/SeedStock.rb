require 'date'

class SeedStock

    attr_accessor :seed_stock
    attr_accessor :mutant_gene_id
    attr_accessor :last_planted
    attr_accessor :storage
    attr_accessor :grams_remaining

    def initialize(params={})
        @seed_stock = params.fetch(:seed_stock, nil)
        @mutant_gene_id = params.fetch(:mutant_gene_id, nil)
        if !validate_gene(@mutant_gene_id)  #Validate gene class
            abort "ERROR: The Arabidopsis gene identifier #{@mutant_gene_id.id} do not have the appropriate format"
        end
        @last_planted = params.fetch(:last_planted, nil)
        @storage = params.fetch(:storage, nil)
        @grams_remaining = params.fetch(:grams_remaining, nil)
    end

    def validate_gene(gene)
        return @mutant_gene_id.is_a?(Gene)
    end

    def verification_seeds(seeds) #Are there enough seeds? (7)
        if seeds-7 > 0  
            return true #enough seeds
        else
            return false #not enough seeds
        end
    end

    def plant_Seeds 
        if @grams_remaining.to_i > 0 #If there is not seeds, we do not change the last date plant
            @last_planted = DateTime.now.strftime('%-d/%-m/%Y') #As we planted today, the new last_planted value is de actual computer date
        end

        if verification_seeds(@grams_remaining.to_i)  #Are there enough seeds? (7)
            @grams_remaining= -7+@grams_remaining.to_i
        else
            puts "WARNING: we have run out of Seed Stock #{@seed_stock}"
            @grams_remaining = 0                      #Seeds cannot be negative
        end 
        
    end
    
end


