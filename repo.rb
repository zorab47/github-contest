require 'lang'

class Repo

    include Comparable

    attr_accessor :id, :name, :source, :date, :forks, :langs, :watchers, :owner

    def initialize
    end

    def initialize(id, name, source, date)
        fields ||= {}

        @id = id
        @name = name
        @source = source
        @date = date
        @forks = []
        @langs = []
        @watchers = []
        @owner = nil
    end

    def to_s
        "Repo ##{id}"
    end

    def major_language 
        langs.sort{ |a,b| a.lines <=> b.lines }.last
    end

    def <=>(other)
        watchers.size <=> other.watchers.size
    end

    def self.new_repo_from(line)
        id, data = line.chomp.split(":")
        name, date, source = data.split(',')
        Repo.new(id.to_i, name, source.to_i, date)

        # Parsing the date to an object is SLOW
        # Repo.new({ :id => id.to_i, :name => name, :source => source.to_i, :date => Date.parse(date) })
    end
end
