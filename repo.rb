require 'lang'

class Repo

    attr_accessor :id, :name, :source, :date, :forks, :langs, :watchers

    def initialize(fields)
        fields ||= {}

        @id = fields[:id] if fields[:id]
        @name = fields[:name] if fields[:name]
        @source = fields[:source] if fields[:source]
        @date = fields[:date] if fields[:date]
        @forks = []
        @langs = []
        @watchers = []
    end

    def to_s
        "Repo ##{id}: #{name}"
    end

    def major_language 
        langs.sort{ |a,b| a.lines <=> b.lines }.last
    end

    def self.new_repo_from(line)
        id, data = line.chomp.split(":")
        name, date, source = data.split(',')
        Repo.new({ :id => id.to_i, :name => name, :source => source.to_i, :date => date })

        # Parsing the date to an object is SLOW
        # Repo.new({ :id => id.to_i, :name => name, :source => source.to_i, :date => Date.parse(date) })
    end
end
