require 'repo'
require 'set'

class User

    attr_accessor :id, :repos

    THRESHOLD = 0.25
    @@verbose = false

    def initialize(id)
        @id = id
        @repos = Set.new
    end

    def to_s
      "UID ##{id}"
    end

    def recommendations(github)

        guesses = Set.new

        guesses += unwatched_fork_sources.uniq[0..2] # limit to 3

        guesses += (overlapping_repos_from_users_with_shared_repos - guesses.to_a)[0..1] # limit to 2

        guesses += (guesses_from_related_repo_owners - guesses.to_a)[0..1] # 2 guesses

        if guesses.size < 10
            guesses += (guesses_from_similar_repos(github.repos.values) - guesses.to_a)[0..9 - guesses.size] # remaining
        end

        if guesses.size < 10
            guesses += (github.popular_repos - guesses.to_a)[0..9 - guesses.size] # fill in
        end

        guesses
    end

    #
    # Provides the top 50 similar repos to this user's repos
    # sorted by similarity.
    #
    def guesses_from_similar_repos(compare)

        # get guesses excluding this user's repos
        guesses = guesses_from_similar_repos_with_similarity((compare.to_set - repos))[0..49]

        # return only the similar non-user repos
        guesses.collect { |c| c[1] }.uniq

    end

    #
    # Provides the top 50 comparisons between the user's repos and
    # the repos provided as @compare@. The format returned is
    # [ [similarity, repo, user_repo], ... ]
    #
    def guesses_from_similar_repos_with_similarity(compare)

        $stderr.puts "In guesses_from_similar_repos_with_similarity()" if $hub_verbose

        # special repos for this user
        special = collect_shared_repos_with_counts

        $stderr.puts "\tspecial_repos has #{special.size} entries" if $hub_verbose

        my_repos = repos

        # if the user follows a great number of repos, shorten it
        # down to the most popular
        if my_repos.size > 19
            $stderr.puts "guesses_from_similar_repos_with_similarity: Slimming down #{self}'s repos ... " if $hub_verbose
            my_repos = my_repos.sort.reverse[0..19]
        end

        # speed up comparisons by excluding repos with few watchers
        compare = compare.delete_if { |r| r.watchers.size < 2 }

        # store array of [similarity, repo1, my_repo1]
        comparisons = []

        compare.each do |repo|

            my_repos.each do |my_repo|

                sim = my_repo.similar(repo, special)

                if sim > THRESHOLD
                    comparisons << [sim, repo, my_repo]
                end

            end

        end

        comparisons = remove_forks_of_same_repo(comparisons)

        comparisons.sort_by { |c| c.first }.reverse

    end

    def collect_shared_repos_with_counts
        special = {}

        users = find_users_with_shared_repos

        special_repos = users.collect { |u| u.repos.to_a }.flatten

        # loop through and count each occurance of a repo
        special_repos.each do |r|
            special[r] ||= 0
            special[r] += 1
        end

        special.delete_if { |r, count| count < 2 }
    end

    def remove_forks_of_same_repo(comparisons)
        comparisons.select { |c| c[1].source.nil? || c[1].watchers.size > 24 }
    end

    def favorite_language

        langs = lang_usages

        if langs.size > 1
            langs.sort{ |a,b| a.last <=> b.last }.last.first
        else
            nil
        end

    end

    def unwatched_fork_sources
        unwatched_sources = (repos.collect{ |r| r.source }.to_set - repos)
        unwatched_sources -= [nil]
        unwatched_sources.sort.reverse
    end

    def guesses_from_related_repo_owners
        $stderr.puts "guesses_from_related_repo_owners" if @@verbose
        owner_repos = repos_from_owners_of_watched_repos

        Repo.restrict_repos_from_each_owner(owner_repos).sort.reverse
    end

    def repos_from_owners_of_watched_repos
        owner_repos = Set.new

        $stderr.puts " repos_from_owners_of_watched_repos .." if @@verbose
        repos.each do |r|
            $stderr.puts " Got repos from #{r.owner}" if @@verbose
            owner_repos += r.owner.repos if r.owner
        end

        owner_repos.flatten - self.repos
    end

    def lang_usages

        usages = get_language_usages

        langs = {}

        usages.each do |usage|
            langs[usage.lang] ||= 0
            langs[usage.lang] += usage.lines
        end

        langs
    end

    def get_language_usages

        usages = Set.new

        usages += repos.collect do |repo|
            repo.lang_usages
        end

        usages.flatten
    end

    def top_repos_by_favorite_lang
        if favorite_language
            (favorite_language.repos - repos).sort.reverse[0..9]
        else
            []
        end
    end

    def friends
        repos.collect{ |repo| repo.watchers }.to_set.flatten
    end

    def friends_repos
        friends.collect{|f| f.repos}.flatten.uniq.sort{|a,b| a.watchers <=> b.watchers}.reverse
    end

    #
    # Located any users watching more than one repos this user is watching
    # ranked by number of shared repos
    #
    def find_users_with_shared_repos

        (friends - [self]).sort_by do |f|
            f.repos.select { |r| repos.collect { |s| s.id }.include?(r.id) }.size
        end.reverse

    end

    #
    # Located any users watching more than one repos this user is watching
    # ranked by number of shared repos
    #
    def overlapping_repos_from_users_with_shared_repos
        users = find_users_with_shared_repos[0..1]

        if users.size > 1
            ((users[0].repos & users[1].repos) - repos).sort.reverse
        else
            []
        end
    end

end
