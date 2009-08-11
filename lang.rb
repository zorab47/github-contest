
class Lang
    attr_accessor :name, :lines

    def initialize(name, lines)
        @name = name
        @lines = lines
    end

    def to_s
        "#{name}: #{lines}"
    end

    def self.new_from(line)

        #JavaScript;9759,ActionScript;12781
        
        langs = []

        lang_pairs = line.split(',')
        lang_pairs.each do |pair|
            langs << Lang.new_from_pair(pair)
        end

        langs
    end

    def self.new_from_pair(pair)
        name, lines = pair.split(';')
        Lang.new(name, lines.to_i)
    end
end
