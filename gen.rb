#!/usr/bin/ruby

require 'hub'

github = Hub.new
github.import_files

test = File.new("test.txt", "r")

while (line = test.gets)
    user_id = line.chomp.to_i

    user = github.users[user_id]

    if user
        out = "#{user_id}:" 
        out +=  github.users[user_id].top_repos_by_favorite_lang.collect{ |r| r.id }.join(",") if user.favorite_language

        puts out
    else
        $stderr.puts "Skipping #{user_id}, it was not found."
    end
end
