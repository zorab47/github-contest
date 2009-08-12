
class Lang

    attr_accessor :name, :repos

    def initialize(name)
        @name = name
        @repos = [] 
    end

    def to_s
        "#{name}"
    end

    def repos_sorted_by_popularity
        return @sorted_by_popularity if @sorted_by_popularity

        $stderr.puts "Sorting language repos by popularity for #{self} ... "
        @sorted_by_popularity = @repos.sort { |a, b| a.watchers.size <=> b.watchers.size }.reverse
    end

end
