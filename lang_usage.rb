
class LangUsage
    attr_accessor :lang, :lines

    def initialize(lang, lines)
        @lang = lang
        @lines = lines
    end

    def to_s
        "#{lang}: #{lines}"
    end
end
