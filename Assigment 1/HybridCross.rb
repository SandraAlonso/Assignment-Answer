class HybridCross

    attr_accessor :parent1
    attr_accessor :parent2
    attr_accessor :f2_wild
    attr_accessor :f2_p1
    attr_accessor :f2_p2
    attr_accessor :f2_p1p2

    def initialize (params={})
        @parent1 = params.fetch(:parent1, nil)
        @parent2 = params.fetch(:parent2, nil)	
        @f2_wild = params.fetch(:f2_wild, nil)	
        @f2_p1 = params.fetch(:f2_p1, nil)	
        @f2_p2 = params.fetch(:f2_p2, nil)	
        @f2_p1p2 = params.fetch(:f2_p1p2, nil)

    end

    def calculate_chi_square(total)
        amount=0.0
        #Chi Square function: [(O-E)^2]/E
            #O=obtained value
            #E=expected value
        
        amount += ((f2_wild.to_i-(total*9/16))**2)/(total*9/16)
        amount += ((f2_p1.to_i-(total*3/16))**2)/(total*3/16)
        amount += ((f2_p2.to_i-(total*3/16))**2)/(total*3/16)
        amount += ((f2_p1p2.to_i-(total*1/16))**2)/(total*1/16)
        return amount
    end

    def chi_square
        total = f2_wild.to_f + f2_p1.to_f + f2_p2.to_f + f2_p1p2.to_f
        amount = calculate_chi_square(total)                            
        if amount > 7.81                                                #chi square value for 3 degrees of freedom
            parent1.add_linked_genes(parent2)  #If genes are linked they are added to the others linked_genes array
            parent2.add_linked_genes(parent1)
            puts "Recording: #{parent1.name} is genetically linked to #{parent2.name} with chisquare score #{amount}"

        end
    end

end