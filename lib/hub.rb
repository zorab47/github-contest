
require 'repo.rb'
require 'user'
require 'lang'
require 'owner'
require 'lang_usage'
require 'overlap'
require 'set'

class Hub

    attr_accessor :repos, :users, :langs, :owners

    def initialize
        @repos = {}
        @users = {}
        @langs = {}
        @owners = {}
    end

    def find_lang(name)
        @langs[name]
    end
    
    def popular_repos
        return @popular_repos if @popular_repos
        @popular_repos = repos.values.sort{|a,b| a.watchers.size <=> b.watchers.size }.reverse
    end

    def popular_repos_by_forks
        return @popular_forked_repos if @popular_forked_repos
        @popular_forked_repos = repos.values.sort_by{|r| r.forks }.reverse
    end

    def import_files
        import(File.new("repos.txt", 'r'), File.new("lang.txt", "r"), File.new("data.txt", "r"), File.new("overlaps-50.txt", "r"))
    end

    def import(repos, langs, users, overlaps = nil)
        import_repos_from(repos)
        import_langs_from(langs)
        import_users_from(users)
        import_overlaps_from(overlaps) if overlaps
    end

    def import_repos_from(repos_file)

        $stderr.puts "Parsing repos ..." 

        @repos = {}

        while (line = repos_file.gets)
            repo = Repo.new_repo_from(line)
            @repos[repo.id] = repo
            owner_name = repo.name.split('/').first

            owner = find_or_create_owner(owner_name)
            owner.repos << repo
            repo.owner = owner
        end

        set_sources
        set_forks

       true
    end

    def find_or_create_owner(name)
        return @owners[name] if @owners[name]

        @owners[name] = Owner.new(name)
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

                # set the repo's major language, if possible
                unless repo.langs.empty?
                    major_usage = repo.langs.sort{ |a,b| a.lines <=> b.lines }.last
                    repo.major_language = major_usage.lang
                    repo.major_lang_usage = major_usage
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

            user = create_or_find_user(user_id)

            if @repos[repo_id]
                user.repos << @repos[repo_id] 
                @repos[repo_id].watchers << user
            end
        end

        true
    end

    def import_overlaps_from(file)

        $stderr.puts "Importing repo watcher overlaps ..." 

        while (line = file.gets)

           repo_id, data = line.split(':')

           repo = @repos[repo_id.to_i]

           unless repo.nil?
           
               pairs = data.split(';')
               pairs.each do |pair|

                   related_repo_id, count = pair.split(',')
                   related_repo = @repos[related_repo_id.to_i]

                   count = count.to_i

                   repo.overlaps << Overlap.new(related_repo, count)

               end

           else
                
               $stderr.puts "#{repo_id} could not be loaded."

           end

        end

    end

    def calculate_overlapps_for_repos

        required_overlap = 50

        repos_with_enough_watchers = repos.values.select{ |r| r.watchers.size > required_overlap }
        repos_to_process = Array.new(repos_with_enough_watchers)

        repos_to_process.each do |r|
            r.calculate_overlaps(repos_with_enough_watchers, required_overlap)
            putc '.'
        end

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
            @repos[source].forks = forks.to_set if @repos[source]
        end
    end

    def create_or_find_lang(name)
        return @langs[name] if @langs.has_key?(name)

        @langs[name] = Lang.new(name)
    end

    def create_or_find_user(uid)
        return @users[uid] if @users.has_key?(uid)

        @users[uid] = User.new(uid)
    end

end
