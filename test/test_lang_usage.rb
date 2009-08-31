
require 'test/unit'
require 'mocha'
require 'lang_usage'

class TestLangUsage < Test::Unit::TestCase

    def test_sorting
        u1 = LangUsage.new("lang1", 1234)
        u2 = LangUsage.new("lang1", 12)
        u3 = LangUsage.new("lang1", 12000)
        u4 = LangUsage.new("lang1", 1590)

        usages = [u1, u2, u3, u4]

        assert_equal [u2, u1, u4, u3], usages.sort
    end

    
end
