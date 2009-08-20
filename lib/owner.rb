class Owner

    attr_accessor :name, :repos

    def initialize(name)
        @name = name
        @repos = []
    end

end
