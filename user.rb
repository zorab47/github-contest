
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

      usages = get_language_usages

      langs = {}

      usages.each do |usage|
          langs[usage.lang] ||= 0
          langs[usage.lang] += usage.lines
      end

      if langs.size > 1
          langs.sort{|a,b| a.last <=> b.last }.last.first
      elsif langs.size > 0
          langs.to_a.last.first
      else
          nil
      end
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
    favorite_language.repos_sorted_by_popularity[1..10]
  end

end
