require 'lang'

class Repo

    include Comparable

    @@cache = {}

    attr_accessor :id, :name, :source, :date, :forks, :langs, :watchers, :owner, :overlaps

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
        @overlaps = []
        @major_language = nil
    end

    def to_s
        "#{name} (#{id})"
    end

    def major_language 
        return nil if langs.empty?
        return @major_language unless @major_language.nil?

        @major_language = langs.sort{ |a,b| a.lines <=> b.lines }.last
    end

    def <=>(other)
        watchers.size <=> other.watchers.size
    end

    #
    # Calculates a repository's watcher overlap with the other repositories
    # provided. This is an expensive calculation as it finds the intersection
    # between this repository's watchers and all other repository's watchers
    #
    def calculate_overlaps(repos, required_overlap = 30)

        (repos - [self]).each do |repo|

            overlapping_watchers = (watchers & repo.watchers)

            if overlapping_watchers.size > required_overlap
                @overlaps << Overlap.new(repo, overlapping_watchers.size)
            end

        end

    end

    #
    # factor of similarity to another repository
    #
    def similar(other)

        sim = 0.0

        # Both repos contain the same major language
        mlang = major_language
        olang = other.major_language
        unless olang.nil? || mlang.nil?
           if mlang.lang == olang.lang
               sim += 0.05
               
               # provided an additional weighting by the closeness of number of lines
               unless mlang.lines == 0 && olang.lines == 0
                   diff = mlang.lines > olang.lines ? olang.lines / mlang.lines : mlang.lines / olang.lines
                   sim += 0.15 * diff
               end
           end
        end

        # Both repos are "owned" by the same account like 'rails/rails' 
        # and 'rails/open_id_authentication'
        if owner
            if owner == other.owner
                sim += 0.25
            end
        end

        unless watchers.empty?

            overlap = nil
            other.overlaps.each do |o|
                if o.repo == self
                    overlap = o
                    break
                end
            end

            if overlap 
                percent_overlap = overlap.overlap * 1.0 / (watchers.size + other.watchers.size - overlap.overlap)
                sim += 5 * percent_overlap
            end

        end

        unless forks.empty?
            # fork of other or visa versa
            if forks.include?(other) || other.forks.include?(self)
                sim += 0.4
            end
        end

        sim

    end

    def self.new_repo_from(line)
        id, data = line.chomp.split(":")
        name, date, source = data.split(',')
        Repo.new(id.to_i, name, source.to_i, date)

        # Parsing the date to an object is SLOW
        # Repo.new({ :id => id.to_i, :name => name, :source => source.to_i, :date => Date.parse(date) })
    end
end
