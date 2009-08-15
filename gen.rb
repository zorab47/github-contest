#!/usr/bin/ruby

require 'hub'

github = Hub.new
github.import_files

test = File.new("test.txt", "r")

while (line = test.gets)
    user_id = line.chomp.to_i

    user = github.users[user_id]
    guesses = []

    if user

        guesses = user.guesses_from_related_repo_owners(github.owners)[0..1] # 2 guesses
        guesses += (user.guesses_by_favorite_lang_and_percentage_of_lang - guesses)[0..1] # 2 guesses
        guesses += (github.popular_repos - guesses)[0..3] # 4 guesses
        guesses += (github.popular_repos_by_forks - guesses)[0..1] # 2 guesses

    else
        $stderr.puts "UID #{user_id} not found in database ..."
        guesses = github.popular_repos[0..10].sort_by{ rand }[0..4]
        guesses += (github.popular_repos_by_forks[0..6].sort_by{rand} - guesses)[0..4] 
    end
    
    out = "#{user_id}:" 
    out +=  guesses.collect{ |r| r.id }.join(",")

    puts out
end
