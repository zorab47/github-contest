
require 'repo'
require 'user'

class Hub

    attr_accessor :repos, :users

    def initialize
        @repos = {}
        @users = {}
    end

    def import_repos_from(repos_file)

        $stderr.puts "Parsing repos ..." 

        while (line = repos_file.gets)
            repo = Repo.new_repo_from(line)
            @repos[repo.id] = repo
        end

        set_sources
        set_forks

        @repos
    end

    def import_langs_from(langs_file)

        $stderr.puts "Parsing langs ..." 

        while (line = langs_file.gets)

            repo_id, data = line.chomp.split(':')
            repo_id = repo_id.to_i

            langs = Lang.new_from(data)
            @repos[repo_id].langs = langs if @repos[repo_id]
        end
    end

    def import_users_from(file)
        $stderr.puts "Parsing users and setting watchers ..." 

        @users = {}

        while (line = file.gets)
            user_id,repo_id = parse_data_line(line)

            user_id = user_id.to_i
            repo_id = repo_id.to_i

            user = @users[user_id] = User.new(user_id)

            if @repos[repo_id]
                user.repos << @repos[repo_id] 
                @repos[repo_id].watchers << user
            end
        end
    end

    private

    def set_sources

        $stderr.puts "Setting repo sources ..." 

        @repos.each_value do |value|
            if value.source && value.source > 0 && @repos.has_key?(value.source)
                source_id = value.source
                value.source = @repos[value.source]
            end
        end
    end

    def set_forks

        $stderr.puts "Setting forks ..." 

        sources = {}
        
        @repos.each_value do |repo|
            if repo.source && repo.source.is_a?(Repo)
                id = repo.source.id
                sources[id] ||= []
                sources[id] << repo
            end
        end

        sources.each_pair do |source, forks|
            @repos[source].forks = forks if @repos[source]
        end
    end

end
