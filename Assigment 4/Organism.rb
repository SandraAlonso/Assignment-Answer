class Organisim
    attr_accessor :file
    attr_accessor :type
    attr_accessor :factory
    attr_accessor :overlap
    attr_accessor :entity

    def initialize (params = {})
        @file = params.fetch(:name,nil)
        @type = params.fetch(:type, nil)
        @factory = params.fetch(:factory, nil)
    end
end
