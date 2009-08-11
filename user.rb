
class User

  attr_accessor :id, :repos

  def initialize(id)
      @id = id
      @repos = []
  end

  def to_s
      "User ##{id}"
  end

end
