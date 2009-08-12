
require 'repo'
require 'user'
require 'lang'
require 'lang_usage'

class Hub

    attr_accessor :repos, :users, :langs

    def initialize
        @repos = {}
        @users = {}
        @langs = {}
    end

    def find_lang(name)
        @langs[name]
    end

    def find_popular_repos_by_lang_for(user)
        
    end

    def import_files
        import(File.new("repos.txt", 'r'), File.new("lang.txt", "r"), File.new("data.txt", "r"))
    end

    def import(repos, langs, users)
        import_repos_from(repos)
        import_langs_from(langs)
        import_users_from(users)
    end

    def import_repos_from(repos_file)

        $stderr.puts "Parsing repos ..." 

        @repos = {}

        while (line = repos_file.gets)
            repo = Repo.new_repo_from(line)
            @repos[repo.id] = repo
        end

        set_sources
        set_forks

       true
    end

    def import_langs_from(langs_file)

        $stderr.puts "Parsing langs ..." 

        @langs = {}

        while (line = langs_file.gets)
            repo_id, data = line.chomp.split(':')
            repo_id = repo_id.to_i

            repo = @repos[repo_id]

            if repo  
                lang_pairs = data.split(',')
                lang_pairs.each do |pair|
                    name, lines = pair.split(';')

                    lang = create_or_find_lang(name)
                    lang.repos << repo

                    usage = LangUsage.new(lang, lines.to_i)
                    repo.langs << usage
                end
            end
        end

        true
    end

    def import_users_from(file)

        $stderr.puts "Parsing users and setting watchers ..." 

        @users = {}

        while (line = file.gets)
            user_id, repo_id = parse_data_line(line)

            user = @users[user_id] = User.new(user_id)

            if @repos[repo_id]
                user.repos << @repos[repo_id] 
                @repos[repo_id].watchers << user
            end
        end

        true
    end

    private
    
    def parse_data_line(line)
        user_id, repo_id = line.chomp.split(':')

        [user_id.to_i, repo_id.to_i]
    end

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

    def create_or_find_lang(name)
        return @langs[name] if @langs.has_key?(name)

        @langs[name] = Lang.new(name)
    end

end
