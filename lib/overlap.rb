
class Overlap

    include Comparable

    attr_accessor :repo, :overlap

    def initialize(repo, overlap)
        @repo = repo
        @overlap = overlap
    end

    def <=>(other)
        overlap <=> other.overlap
    end

    def to_s
        "#{repo}: #{overlap}"
    end

end
