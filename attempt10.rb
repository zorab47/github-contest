#!/usr/bin/ruby

Object.send :undef_method, :id

require 'rubygems'
require 'ruby-prof'

require 'hub'


def suggest_for(user_id, github)
    user = github.users[user_id]
    guesses = []

    if user

        guesses = user.unwatched_fork_sources.uniq[0..2] # limit to 3
        guesses = guesses.select{ |g| g.is_a?(Repo) }

        guesses += (user.guesses_from_similar_repos(github.repos.values) - guesses)[0..3] # 4 guesses
        guesses = guesses.select{ |g| g.is_a?(Repo) }

        guesses += (user.guesses_from_related_repo_owners(github.owners) - guesses)[0..0] # 1 guesses
        guesses = guesses.select{ |g| g.is_a?(Repo) }

        guesses += (user.guesses_by_favorite_lang_and_percentage_of_lang - guesses)[0..0] # 1 guesses
        guesses = guesses.select{ |g| g.is_a?(Repo) }

        guesses += (github.popular_repos - guesses)[0..0] # 1 guesses
        guesses = guesses.select{ |g| g.is_a?(Repo) }

        if guesses.size < 10
            guesses += (github.popular_repos_by_forks - guesses)[0..(9 - guesses.size)] # remainder
        end

    else
        $stderr.puts "UID #{user_id} not found in database ..."
        guesses = github.popular_repos[0..10].sort_by{ rand }[0..4]
        guesses += (github.popular_repos_by_forks[0..6].sort_by{rand} - guesses)[0..4] 
    end

    $stderr.puts "#{user}: " + guesses.join(", ")
    
    out = "#{user_id}:" + guesses.collect{ |r| r.id }.join(",")

    puts out
end

#RubyProf.start

$stdout.sync = true

github = Hub.new
github.import_files

test = File.new("test.txt", "r")

user_ids = []

while (line = test.gets)
    user_ids << line.chomp.to_i
end

user_ids.reverse.take(2019).each do |id|
    suggest_for(id, github)
end



#result = RubyProf.stop

# Print a flat profile to text
#printer = RubyProf::GraphPrinter.new(result)
#printer.print(STDOUT, 0)

