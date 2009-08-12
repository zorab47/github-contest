
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

      usages = {}

      repos.each do |r|
          r.langs do |l|
              usages[l.lang.name] ||= 0
              usages[l.lang.name] += l.lines
          end
      end

      usages.sort{|a,b| a.last <=> b.last}
  end

end
