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

        guesses = user.guesses_by_favorite_lang_and_percentage_of_lang
        guesses += github.popular_repos[0..(10 - guesses.size)]

    else
        $stderr.puts "UID #{user_id} not found in database ..."
        guesses = github.popular_repos[0..9]
    end
    
    out = "#{user_id}:" 
    out +=  guesses.collect{ |r| r.id }.join(",")

    puts out
end
