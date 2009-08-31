
require 'test/unit'
require 'repo'
require 'owner'
require 'set'

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
        
        assert_equal [repo1, repo2, repo4].to_set, Repo.restrict_repos_from_each_owner(repos)
        assert_equal [repo1, repo4].to_set, Repo.restrict_repos_from_each_owner(repos, 1)
    end

    def test_sorting

        repo1 = Repo.new
        repo1.watchers = [1, 2, 3, 4].to_set

        repo2 = Repo.new
        repo2.watchers = nil

        repo3 = Repo.new
        repo3.watchers = [1, 2].to_set

        repo4 = Repo.new
        repo4.watchers = [1, 2, 3, 4, 5].to_set

        repos = [repo1, repo2, repo3, repo4, 4]

        assert_equal [repo3, repo1, repo4, repo2, 4], repos.sort
    end

    def test_calculate_owner_name

        r1 = Repo.new(1)
        r1.name = "name/repository_name"

        assert_equal "name", r1.calculate_owner_name

    end
end
