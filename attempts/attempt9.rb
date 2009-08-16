#!/usr/bin/ruby

Object.send :undef_method, :id

require 'hub'

github = Hub.new
github.import_files

test = File.new("test.txt", "r")

while (line = test.gets)
    user_id = line.chomp.to_i

    user = github.users[user_id]
    guesses = []

    if user

        guesses = user.unwatched_fork_sources.uniq[0..2] # limit to 3
        guesses = guesses.select{ |g| g.is_a?(Repo) }
        guesses += (user.guesses_from_related_repo_owners(github.owners) - guesses)[0..1] # 2 guesses
        guesses = guesses.select{ |g| g.is_a?(Repo) }
        guesses += (user.guesses_by_favorite_lang_and_percentage_of_lang - guesses)[0..1] # 2 guesses
        guesses = guesses.select{ |g| g.is_a?(Repo) }
        guesses += (github.popular_repos - guesses)[0..1] # 2 guesses
        guesses = guesses.select{ |g| g.is_a?(Repo) }
        guesses += (github.popular_repos_by_forks - guesses)[0..(9 - guesses.size)] # remainder

    else
        $stderr.puts "UID #{user_id} not found in database ..."
        guesses = github.popular_repos[0..10].sort_by{ rand }[0..4]
        guesses += (github.popular_repos_by_forks[0..6].sort_by{rand} - guesses)[0..4] 
    end

    $stderr.puts guesses.join(", ")
    
    out = "#{user_id}:" 
    out +=  guesses.collect{ |r| r.id }.join(",")

    puts out
end
