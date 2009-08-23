require 'test/unit'
require 'user'
require 'rubygems'
require 'mocha'
require 'set'

class TestUser < Test::Unit::TestCase

    def test_collect_shared_repos_with_counts
        user1 = User.new(1)
        user2 = User.new(2)
        user3 = User.new(3)
        user4 = User.new(4)

        repo1 = Repo.new(1)
        repo2 = Repo.new(2)
        repo3 = Repo.new(3)
        repo4 = Repo.new(4)

        user2.expects(:repos).returns([repo1, repo2, repo4].to_set)
        user3.expects(:repos).returns([repo2, repo3, repo4].to_set)
        user4.expects(:repos).returns([repo2].to_set)

        user1.expects(:find_users_with_shared_repos).returns([user2, user3, user4])
        user2.expects(:find_users_with_shared_repos).returns([])

        assert_equal({ repo2 => 3, repo4 => 2 }, user1.collect_shared_repos_with_counts)
        assert_equal({}, user2.collect_shared_repos_with_counts)
    end

    def test_friends

        r1 = Repo.new(1)
        r1.watchers = Set.new [1, 2, 3, 4, 5]

        r2 = Repo.new(2)
        r2.watchers = Set.new [1, 6]

        user1 = User.new(1)
        user1.expects(:repos).returns([r1, r2].to_set)

        assert_equal [1, 2, 3, 4, 5, 6].to_set, user1.friends

    end

    def test_find_users_with_shared_repos

        user1 = User.new(1)
        user1.stubs(:repos).returns([stub(:id => 1), stub(:id => 2), stub(:id => 5)])

        user2 = User.new(2)
        user2.expects(:repos).returns([stub(:id => 1), stub(:id => 2), stub(:id => 3)])

        user3 = User.new(3)
        user3.expects(:repos).returns([stub(:id => 4)])

        user4 = User.new(4)
        user4.expects(:repos).returns([stub(:id => 1), stub(:id => 2), stub(:id => 5)])

        user1.expects(:friends).returns([user2, user3, user4].to_set)

        assert_equal [user4, user2, user3], user1.find_users_with_shared_repos

    end

    def test_guesses_from_similar_repos_with_similarity

        Repo.any_instance.stubs(:watchers).returns([1, 2])
        Repo.any_instance.stubs(:source).returns(nil)

        repo1 = Repo.new(1)
        repo2 = Repo.new(2)
        repo3 = Repo.new(3)
        repo4 = Repo.new(4)

        repos = [repo1, repo2, repo3, repo4]

        repo5 = Repo.new(5)

        user = User.new(1)
        user.stubs(:collect_shared_repos_with_counts).returns([])
        user.expects(:repos).returns([repo5, repo1].to_set)

        repo5.expects(:similar).with(repo1, []).returns(0.3)
        repo5.expects(:similar).with(repo2, []).returns(0)
        repo5.expects(:similar).with(repo3, []).returns(1.2)
        repo5.expects(:similar).with(repo4, []).returns(0.6)

        repo1.expects(:similar).with(repo1, []).returns(5)
        repo1.expects(:similar).with(repo2, []).returns(0.5)
        repo1.expects(:similar).with(repo3, []).returns(0.7364)
        repo1.expects(:similar).with(repo4, []).returns(0.1)

        expected = [
            [5,      repo1, repo1],
            [1.2,    repo3, repo5],
            [0.7364, repo3, repo1],
            [0.6,    repo4, repo5],
            [0.5,    repo2, repo1],
            [0.3,    repo1, repo5]
        ]
        
        guesses = user.guesses_from_similar_repos_with_similarity(repos)

        assert_equal expected, guesses

    end

    def test_guesses_from_similar_repos
        
        user = User.new(1)

        Repo.any_instance.stubs(:watchers).returns([1, 2])
        Repo.any_instance.stubs(:source).returns(nil)

        repo1 = Repo.new(1)
        repo2 = Repo.new(2)
        repo3 = Repo.new(3)
        repo4 = Repo.new(4)

        repos = [repo1, repo2, repo3, repo4]

        repo5 = Repo.new(5)

        guesses_with_similarity = [
            [5,      repo1, repo1],
            [1.2,    repo3, repo5],
            [0.7364, repo3, repo1],
            [0.6,    repo4, repo5],
            [0.5,    repo2, repo1],
            [0.3,    repo1, repo5]
        ]

        user.expects(:repos).returns([repo5, repo1].to_set)
        user.expects(:guesses_from_similar_repos_with_similarity).with([repo2, repo3, repo4].to_set).returns(guesses_with_similarity)

        expected = [repo1, repo3, repo4, repo2]

        assert_equal expected, user.guesses_from_similar_repos(repos)
    end

    def test_remove_forks_of_same_repo

        repo1 = mock()
        repo1.stubs(:source).returns(nil)

        repo2 = mock()
        repo2.expects(:source).returns(1)
        repo2.expects(:watchers).returns((0..2).to_a)

        repo3 = mock()
        repo3.expects(:source).returns(1)
        repo3.expects(:watchers).returns((0..30).to_a)

        comparisions = [
            [5,      repo1, repo1],
            [1.2,    repo2, repo1],
            [0.7364, repo3, repo1]
        ]

        expected = [
            [5,      repo1, repo1],
            [0.7364, repo3, repo1]
        ]

        user = User.new(1)

        assert_equal expected, user.remove_forks_of_same_repo(comparisions)
    end

    def test_get_language_usages

        repo1 = mock()
        repo1.expects(:lang_usages).returns((1..4).to_set)

        repo2 = mock()
        repo2.expects(:lang_usages).returns((5..8).to_set)

        user = User.new(1)
        user.expects(:repos).returns([repo1, repo2].to_set)

        assert_equal (1..8).to_set, user.get_language_usages
        
    end

    def test_lang_usages

        ruby = Lang.new('Ruby')
        javascript = Lang.new('Javascript')
        java = Lang.new('Java')

        usage1 = stub(:lang => ruby,        :lines => 2000)
        usage2 = stub(:lang => javascript,  :lines => 394)
        usage3 = stub(:lang => java,        :lines => 1233)
        usage4 = stub(:lang => ruby,        :lines => 1093)

        user = User.new(1)
        user.expects(:get_language_usages).returns([usage1, usage2, usage3, usage4])

        expected = { ruby => 3093, javascript => 394, java => 1233 }

        assert_equal expected, user.lang_usages

    end

    def test_favorite_language

        ruby = Lang.new('Ruby')
        javascript = Lang.new('Javascript')
        java = Lang.new('Java')
        
        usages = { ruby => 3093, javascript => 394, java => 1233 }

        user = User.new(1)
        user.expects(:lang_usages).returns(usages)

        assert_equal ruby, user.favorite_language

        user2 = User.new(2)
        user2.expects(:lang_usages).returns([])
        assert_nil user2.favorite_language

    end

end
