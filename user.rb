
class User

  attr_accessor :id, :repos

  def initialize(id)
      @id = id
      @repos = []
  end

  def to_s
      "User ##{id}"
  end

  def favorite_language

      langs = lang_usages

      if langs.size > 1
          langs.sort{|a,b| a.last <=> b.last }
      elsif langs.size > 0
          langs.to_a.last
      else
          nil
      end

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

        if guesses.size < 10
            $stderr.puts "#{self} needs more guesses at #{guesses.size}"
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
