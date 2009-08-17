
class User

  attr_accessor :id, :repos

  THRESHOLD = 0.25

  def initialize(id)
      @id = id
      @repos = []
  end

  def to_s
      "User ##{id}"
  end

  def recommendations(github)
      guesses = []

      guesses = unwatched_fork_sources.uniq.take(4) # limit to 4
      guesses = guesses.select{ |g| g.is_a?(Repo) }

      guesses += (guesses_by_favorite_lang_and_percentage_of_lang - guesses).take(1) # 1 guess

      if guesses.size < 10
          guesses += (guesses_from_similar_repos(github.repos.values) - guesses).take(10 - guesses.size) # remaining
      end

      if guesses.size < 10
          guesses += (github.popular_repos - guesses).take(10 - guesses.size) # remaining
      end

      #$stderr.puts "#{id}: " + guesses.join(", ")

      out = "#{id}:" + guesses.collect{ |r| r.id }.join(",")

      puts out

      guesses
  end

  #
  # Provides the top 50 similar repos to this user's repos
  # sorted by similarity.
  #
  def guesses_from_similar_repos(compare)

      # get guesses excluding this user's repos
      guesses = guesses_from_similar_repos_with_similarity((compare - repos)).take(50)

      # return only the similar non-user repos
      guesses.collect { |c| c[1] }.uniq

  end

  
  #
  # Provides the top 50 comparisons between the user's repos and
  # the repos provided as @compare@. The format returned is 
  # [ [similarity, repo, user_repo], ... ]
  #
  def guesses_from_similar_repos_with_similarity(compare)

      # store array of [Repo, similarity]
      comparisons = []

      my_repos = repos

      # if the user follows a great number of repos, shorten it
      # down to the most popular
      if repos.size > 19 
          $stderr.puts "guesses_from_similar_repos_with_similarity: Slimming down #{self}'s repos ... "
          my_repos = repos.sort.reverse.take(20)
      end

      # speed up comparisons by excluding repos with few watchers
      compare = compare.delete_if { |r| r.watchers.size < 2 }

      compare.each do |r|

          my_repos.each do |s|

              sim = s.similar(r)

              if sim > THRESHOLD
                  comparisons << [sim, r, s]
              end


          end

      end

      comparisons = remove_forks_of_same_repo(comparisons)

      comparisons.sort_by { |c| c.first }.reverse

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
      (repos.collect{ |r| r.source } - repos)
  end

  def guesses_from_related_repo_owners(owners)
      
      return [] if repos.empty?

      owner = repos.first.owner

      return [] if owner.nil?
      
      # the owner's other repos sorted by watcher count, excluding my repos
      return (owners[owner].sort.reverse - repos).select{ |r| r.watchers.size > 4 }
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

        guesses[0..9]
    end


  def friends
      repos.collect{|repo| repo.watchers}.flatten.uniq
  end

  def friends_repos
      friends.collect{|f| f.repos}.flatten.uniq.sort{|a,b| a.watchers <=> b.watchers}.reverse
  end

end
