
class Network_Genes
    attr_accessor :id
    attr_accessor :prot_id
    attr_accessor :kegg
    attr_accessor :go
    attr_accessor :coexpressed_genes
    attr_accessor :father


    def initialize(params ={})
        @id = params.fetch(:id, nil)                                    #gene id
        @father = params.fetch(:father, nil)                            #father of the gene (previous gene of coexpressed)
        @coexpressed_genes = params.fetch(:coexpressed_genes, [])       #coexpressed genes with the current gene
        @prot_id = params.fetch(:prot_id, nil)                          #proteines of the gene
        @kegg = params.fetch(:kegg, nil)                                #kegg info of the gene
        @go = params.fetch(:go, nil)                                    #go info of the gene
    end
end