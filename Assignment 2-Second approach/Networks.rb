class Networks
    attr_accessor :name
    attr_accessor :genes
    attr_accessor :genes
    attr_accessor :list_genes
    attr_accessor :list_genes_names
    @@all_networks = Array.new
    @@final_nets = Array.new

    def initialize(params ={})
        @name = params.fetch(:name, nil)                            #The name of the net will be the fathers id                            
        @genes = params.fetch(:genes, [])                           #List of genes which are not included in the Arabidopsis list but they are connectors between the included ones
        @list_genes = params.fetch(:list_genes, [])                 #List of genes included on the Arabidopsis initial list 
        @list_genes_names = params.fetch(:list_genes_names, [])     #List of genes names included on the Arabidopsis list
        if !@name.nil?                                              #If we have created the net (and not just a call to the class for using its functions), we include them on the list of networks
            @@all_networks << self
        end
    end

    def find_network(name)              #Finding a network by its fathers name
        @@all_networks.each do |net|
            if net.name == name
                return true
            end
        end
        return false
    end

    def get_network (name)              #Getting the network by its father name
        @@all_networks.each do |net|
            if net.name == name
                return net
            end
        end
        return nil
    end

    def get_final_networks              #Return the non-repited networks
        return @@final_nets
    end

    def find_repeated_networks()        #Eliminates the repited networks
        @@all_networks.each do |net|    #We compare each networks with the rest
            included = false
            @@all_networks.each do |net2|
                if net2.name != net.name && (net.list_genes_names-net2.list_genes_names).empty? #If they are not the same network and the second one is included in the first one
                    included = true
                end
            end
            if !included                #If the current net is not included in any net, we add it to the final_net array
                @@final_nets.push(net)
            end
        end

    end
end