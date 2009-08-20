
require 'test/unit'
require 'repo'
require 'owner'

class TestRepo < Test::Unit::TestCase

    def test_restrict_repos_from_each_owner

        owner = Owner.new('name')
        owner2 = Owner.new('name')

        repo1 = Repo.new
        repo1.owner = owner

        repo2 = Repo.new
        repo2.owner = owner

        repo3 = Repo.new
        repo3.owner = owner

        repo4 = Repo.new
        repo4.owner = owner2

        repos = [repo1, repo2, repo3, repo4]
        
        assert_equal [repo1, repo2, repo4], Repo.restrict_repos_from_each_owner(repos)
        assert_equal [repo1, repo4], Repo.restrict_repos_from_each_owner(repos, 1)
    end
end
