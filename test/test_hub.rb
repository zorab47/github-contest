
require 'test/unit'
require 'mocha'
require 'hub'

class TestHub < Test::Unit::TestCase

    def setup

        @repo1 = Repo.new(7, "exploid/chat", nil, "2008-07-18")
        @repo1.owner = Owner.new("exploid")
        @repo1.owner.repos << @repo1

        @repo2 = Repo.new(8, "aslakhellesoy/cucumber", nil, "2008-04-17")
        @repo2.owner = Owner.new("aslakhellesoy")
        @repo2.owner.repos << @repo2

        @repo3 = Repo.new(11, "jessesielaff/red", nil, nil)
        @repo3.owner = Owner.new("jessesielaff")
        @repo3.owner.repos << @repo3

        @repo4 = Repo.new(12, "nanodeath/modulo", 7, "2008-07-18")
        @repo4.owner = Owner.new("nanodeath")
        @repo4.owner.repos << @repo4
        @repo4.source = @repo1

        # forks
        @repo1.forks << @repo4

        @repos = { 7 => @repo1, 8 => @repo2, 11 => @repo3, 12 => @repo4 }


        # Langs data
        @lang1 = Lang.new("JavaScript")
        @lang1.repos << @repo1

        @lang2 = Lang.new("Ruby")
        @lang2.repos << @repo1
        @lang2.repos << @repo2
        @lang2.repos << @repo3

        @lang3 = Lang.new("C Sharp")
        @lang3.repos << @repo2

        @lang4 = Lang.new("Java")
        @lang4.repos << @repo2

        @langs = { "JavaScript" => @lang1, "Ruby" => @lang2, "C Sharp" => @lang3, "Java" => @lang4 }

    end

    def test_import_repos_from

        file = mock()
        file.stubs(:gets).returns(
            "7:exploid/chat,2008-07-18",
            "8:aslakhellesoy/cucumber,2008-04-17",
            "11:jessesielaff/red",
            "12:nanodeath/modulo,2009-01-16,7"
        ).then.returns(nil)

        hub = Hub.new
        hub.import_repos_from(file)

        expected = @repos

        assert_equal expected, hub.repos

        expected.each_pair do |key, repo|
            assert_equal repo.source, hub.repos[key].source
            assert_equal repo.owner.name, hub.repos[key].owner.name
            assert_equal repo.owner.repos.to_a, hub.repos[key].owner.repos.to_a
            assert_equal repo.forks.to_a, hub.repos[key].forks.to_a
        end

    end

    def test_import_langs_from

        repofile = mock()
        repofile.stubs(:gets).returns(
            "7:exploid/chat,2008-07-18",
            "8:aslakhellesoy/cucumber,2008-04-17",
            "11:jessesielaff/red",
            "12:nanodeath/modulo,2009-01-16,7"
        ).then.returns(nil)

        langfile = mock()
        langfile.stubs(:gets).returns(
            "7:JavaScript;2305,Ruby;6207",
            "8:C Sharp;339,Java;355,Ruby;319537",
            "11:Ruby;260356"
        ).then.returns(nil)

        hub = Hub.new
        hub.import_repos_from(repofile)
        hub.import_langs_from(langfile)

        @repo1.lang_usages << LangUsage.new(@lang1, 2305)
        @repo1.lang_usages << LangUsage.new(@lang2, 6207)
        @repo1.major_language = @lang2

        @repo2.lang_usages << LangUsage.new(@lang3, 339)
        @repo2.lang_usages << LangUsage.new(@lang4, 355)
        @repo2.lang_usages << LangUsage.new(@lang2, 319537)
        @repo2.major_language = @lang2

        @repo3.lang_usages << LangUsage.new(@lang2, 260356)
        @repo3.major_language = @lang2

        @langs.each_pair do |key, lang|
            compare = hub.langs[key]

            assert hub.langs.has_key?(key)
            assert_equal lang.name, compare.name
            assert_equal lang.repos, compare.repos
        end

        @repos.each_pair do |key, repo|
            compare = hub.repos[key]
            assert_not_nil compare

            if repo.major_language.nil?
                assert_nil compare.major_language
            else
                assert_equal repo.major_language.name, compare.major_language.name
            end

            repo.lang_usages.each do |usage|
                x = compare.lang_usages.select { |u| u.lang.name == usage.lang.name }.first
                assert_not_nil x
                assert_equal usage.lang.name, x.lang.name
                assert_equal usage.lines, x.lines
            end
        end

    end

    def test_import_users_from

        userfile = mock()
        userfile.stubs(:gets).returns(
            "7:7",
            "2708:7",
            "32023:7",
            "984:7",
            "4960:7",
            "166:11",
            "482:11"
        ).then.returns(nil)

        u1 = User.new(7)
        u2 = User.new(2708)
        u3 = User.new(32023)
        u4 = User.new(984)
        u5 = User.new(4960)
        u6 = User.new(166)
        u7 = User.new(482)

        users = { 7 => u1, 2708 => u2, 32023 => u3, 984 => u4, 4960 => u5, 166 => u6, 482 => u7 }

        hub = Hub.new
        hub.repos = @repos
        hub.import_users_from(userfile)

        users.each_pair do |key, user|
            assert hub.users.has_key?(key)

            x = hub.users[key]
            assert_equal user.id, x.id
            assert_equal 1, x.repos.size
        end

        assert_equal 5, hub.repos[7].watchers.size
        assert_equal 2, hub.repos[11].watchers.size
        assert_equal 0, hub.repos[8].watchers.size
        assert_equal 0, hub.repos[12].watchers.size

    end

end
