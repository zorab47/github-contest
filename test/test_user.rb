require 'test/unit'
require 'user'
require 'rubygems'
require 'mocha'

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

        user2.expects(:repos).returns([repo1, repo2, repo4])
        user3.expects(:repos).returns([repo2, repo3, repo4])
        user4.expects(:repos).returns([repo2])

        user1.expects(:find_users_with_shared_repos).returns([user2, user3, user4])
        user2.expects(:find_users_with_shared_repos).returns([])

        assert_equal({ repo2.id => 3, repo4.id => 2 }, user1.collect_shared_repos_with_counts)
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

end
