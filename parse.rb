#!/usr/bin/ruby

Object.send :undef_method, :id

require 'hub'


def parse_data_line(line)
    line.chomp.split(":")
end

def parse_data_file(users)
  data = File.new("data.txt", "r")

  while (line = data.gets)
    user_id,repo_id = parse_data_line(line)
    users[user_id] ||= { :repos => [] }
    users[user_id][:repos] << repo_id.to_i
  end
end

def show(records)
    records.each do |record| 
        puts record
    end
end

def attempt7(github)

    uids = [1477, 4242, 981, 7203, 34174, 19025, 21631]
    uids.each do |uid|
        u = github.users[uid]

        guesses = u.guesses_from_related_repo_owners(github.owners)

        puts "#{u} guesses from related repo owners:"
        unless guesses.empty?
            guesses.each do |g|
                puts "\tRepo #{g} by #{g.owner} with #{g.watchers.size} watchers"
            end
        else
            puts "\tNo guesses picking 5 random repos from the popular ones"

            github.popular_repos[0..30].sort_by{ rand }[0..4].each do |r|
                puts "\t\tRepo #{r} by #{r.owner} with #{r.watchers.size} watchers"
            end
            
        end

    end

end

def attempt6(github)
    
    uids = [1477, 4242, 981, 7203, 34174]

    uids.each do |uid|
        u = github.users[uid]

        fav = u.favorite_language.flatten
        
        unless fav.empty?
            puts "#{u} likes #{fav.first.name}, but also uses " + (fav - [fav.first]).join(', ')

            if u.repos.size > 0
                owner = u.repos.first.owner
                github.owners[owner].sort.reverse[0..2].each do |r|
                    puts "\tRepos #{r} is popular by #{owner} with #{r.watchers.size} watchers"

                    if r.source.is_a?(Repo)
                        puts "\t\tRepo #{r} was forked from #{r.source} (watchers: #{r.source.watchers.size}"
                    end
                end
            end

        else
            puts "#{u} does not have a favorite lang"
        end
    end

end

def attempt5(github)

    puts "Top popular repos by watchers: "
    github.popular_repos[0..10].each do |r|
        puts "\t#{r} #{r.watchers.size}"
    end

    puts "Top popular repos by watchers + forks: "
    pop = github.repos.values.sort{|a,b| (a.watchers.size + a.forks.size) <=> (b.watchers.size + b.forks.size) }.reverse
    pop[0..10].each do |r|
        puts "\t#{r} #{r.watchers.size} + #{r.forks.size} = #{r.watchers.size + r.forks.size}"
    end

end



# Check for overlapping repositories between users

def attmpt4

    test_users = Array.new(github.users.values)

    github.users.values.each do |u|
        puts "Checking #{u} ..."
        test_users.each do |t|
            matches = t.repos.select{|r| u.repos.include?(r)}.size
            if matches > 0
                puts "\t#{u} has #{matches} of the same repos as #{t}"
            end
        end

        # remove user u so it is not compared again
        test_users.delete(u)
    end

end

github = Hub.new
github.import_files

puts " ...done\n"

attempt7(github)


#puts " ... done."
#
#uids = [1477, 4242, 981, 7203, 34174]
#
#uids.each do |uid|
#    u = github.users[uid]
#    puts "#{u}: " + u.guesses_by_favorite_lang_and_percentage_of_lang.join(",")
#end
