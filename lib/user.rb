require 'repo'

class User

    attr_accessor :id, :repos

    THRESHOLD = 0.25
    @@verbose = false

    def initialize(id)
        @id = id
        @repos = []
    end

    def to_s
      "User ##{id}"
    end

    def recommendations(github)

        guesses = []

        guesses = unwatched_fork_sources.uniq[0..2] # limit to 3

        #guesses += (overlapping_repos_from_users_with_shared_repos - guesses)[0..5] # limit to 4

        #guesses += (guesses_from_related_repo_owners - guesses)[0..3] # 3 guesses

        if guesses.size < 10
            guesses += (guesses_from_similar_repos(github.repos.values) - guesses)[0..10 - guesses.size] # remaining
        end

        if guesses.size < 10
            guesses += (github.popular_repos - guesses)[0..10 - guesses.size] # fill in
        end

        guesses
    end

    #
    # Provides the top 50 similar repos to this user's repos
    # sorted by similarity.
    #
    def guesses_from_similar_repos(compare)

        # get guesses excluding this user's repos
        guesses = guesses_from_similar_repos_with_similarity((compare - repos))[0..49]

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

        # store array of [Repo, similarity]
        comparisons = []

        my_repos = repos

        # if the user follows a great number of repos, shorten it
        # down to the most popular
        if repos.size > 19
            $stderr.puts "guesses_from_similar_repos_with_similarity: Slimming down #{self}'s repos ... " if $hub_verbose
            my_repos = repos.sort.reverse[0..19]
        end

        # speed up comparisons by excluding repos with few watchers
        compare = compare.delete_if { |r| r.watchers.size < 2 }

        compare.each do |r|

            my_repos.each do |s|

                sim = s.similar(r, special)

                if sim > THRESHOLD
                    comparisons << [sim, r, s]
                end

            end

        end

        comparisons = remove_forks_of_same_repo(comparisons)

        comparisons.uniq.sort_by { |c| c.first }.reverse

    end

    def collect_shared_repos_with_counts
        special = {}

        special_repos = find_users_with_shared_repos.collect { |u| u.repos }.flatten
        # loop through and count each occurance of a repo
        special_repos.each do |r|
            special[r.id] ||= 0
            special[r.id] += 1
        end

        special
    end

    def remove_forks_of_same_repo(comparisons)
        comparisons.select { |c| c[1].source.nil? || c[1].watchers.size > 24 }
    end

    def favorite_language

        langs = lang_usages

        if langs.size > 1
            langs.sort{|a,b| a.last <=> b.last }
        elsif langs.size > 0
            langs.to_a
        else
            []
        end

    end

    def unwatched_fork_sources
        unwatched_sources = (repos.collect{ |r| r.source } - repos)
        unwatched_sources.select { |r| r.is_a?(Repo) }.uniq.sort.reverse
    end

    def guesses_from_related_repo_owners
        $stderr.puts "guesses_from_related_repo_owners" if @@verbose
        owner_repos = repos_from_owners_of_watched_repos

        Repo.restrict_repos_from_each_owner(owner_repos).uniq.sort_by { |r| r.watchers.size }.reverse
    end

    def repos_from_owners_of_watched_repos
        owner_repos = []

        $stderr.puts " repos_from_owners_of_watched_repos .." if @@verbose
        repos.each do |r|
            $stderr.puts " Got repos from #{r.owner}" if @@verbose
            owner_repos << r.owner.repos
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

        usages = []

        @repos.each do |repo|
            repo.langs.each do |usage|
                usages << usage
            end
        end

        usages
    end

    def top_repos_by_favorite_lang
        if favorite_language
            (favorite_language.repos_sorted_by_popularity - repos)[0..9]
        else
            []
        end
    end

    def guesses_by_favorite_lang_and_percentage_of_lang

        total_lines = 0
        guesses = []

        langs = lang_usages

        langs.each_pair do |key, value|
            total_lines += value
        end

        langs.each_pair do |key, value|
            begin
                count = value.to_f / total_lines * 10
                count = count.to_i
            rescue
                count = 0
            end

            guesses += (key.repos_sorted_by_popularity - repos)[0..count]
        end

        guesses.uniq[0..9]
    end


    def friends
        repos.collect{ |repo| repo.watchers }.flatten.uniq
    end

    def friends_repos
        friends.collect{|f| f.repos}.flatten.uniq.sort{|a,b| a.watchers <=> b.watchers}.reverse
    end

    #
    # Located any users watching more than one repos this user is watching
    # ranked by number of shared repos
    #
    def find_users_with_shared_repos

        @users_with_shared_repos = (friends - [self]).sort_by do |f|
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
