require 'lang'
require 'owner'
require 'set'

class Repo

    include Comparable

    @@cache = {}

    attr_accessor :id, :name, :source, :date, :forks, :lang_usages, :watchers, :owner, :overlaps, :major_language, :major_lang_usage

    def initialize
    end

    def initialize(id = nil, name = nil, source = nil, date = nil)

        @id = id
        @name = name
        @source = source
        @date = date
        @forks = Set.new
        @lang_usages = Set.new
        @watchers = Set.new
        @owner = nil
        @overlaps = []
        @major_language = nil
        @major_lang_usage = nil
    end

    def to_s
        "#{name} (#{id})"
    end

    def <=>(other)

        unless other.is_a?(Repo)
            return -1
        end

        if watchers.is_a?(Array) && other.watchers.is_a?(Array)
            return watchers.size <=> other.watchers.size
        elsif watchers.is_a?(Array)
            return -1
        elsif other.watchers.is_a?(Array) 
            return 1
        else
            return 0
        end
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
    # factor of similarity to another repository and provide
    # additional tweaks based on the intended user via
    # the special_repos variable
    #
    def similar(other, special_repos = [])

        unless other.is_a?(Repo)
            raise "Cannot compare a repo to a non-repo object"
        end

        sim = 0.0

        # Both repos contain the same major language
        mlang = major_lang_usage
        olang = other.major_lang_usage
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

            overlap = other.overlaps.select { |o| o.repo == self }.first

            unless overlap.nil?
                percent_overlap = overlap.overlap * 1.0 / (watchers.size + other.watchers.size - overlap.overlap)
                sim += 5 * percent_overlap
            end

        end

        unless forks.empty?
            # fork of other or visa versa
            if forks.include?(other) || other.forks.include?(self)
                sim += 0.25
            end
        end

        unless source.nil?
            if source == other || other.source == self
                sim += 0.7
            end
        end

        unless special_repos.empty?
            if special_repos.has_key?(self) && special_repos.has_key?(other)
                sim += 0.7 * (special_repos[self] + special_repos[other])
            end
        end

        sim

    end

    def calculate_owner_name
        @name.split('/').first
    end

    def self.new_repo_from(line)
        id, data = line.chomp.split(":")
        name, date, source = data.split(',')
        Repo.new(id.to_i, name, source.to_i, date)

        # Parsing the date to an object is SLOW
        # Repo.new({ :id => id.to_i, :name => name, :source => source.to_i, :date => Date.parse(date) })
    end

    def self.restrict_repos_from_each_owner(repositories, count = 2)

        repos_from_owner = {}

        repositories.each do |r|
            repos_from_owner[r.owner]  ||= []
            repos_from_owner[r.owner] << r
        end

        repos_from_owner.values.collect { |v| v[0..count - 1] }.flatten.to_set

    end
end
