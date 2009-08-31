
require 'set'

class Owner

    attr_accessor :name, :repos

    def initialize(name)
        @name = name
        @repos = Set.new
    end

end
