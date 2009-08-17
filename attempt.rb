#!/usr/bin/ruby1.9

require 'hub'

$stdout.sync = true

VERBOSE = false

github = Hub.new
github.import_files

test = File.new("test.txt", "r")

user_ids = []

while (line = test.gets)
    user_ids << line.chomp.to_i
end

user_ids = user_ids.shuffle

half = (user_ids.size / 2).to_i

first = user_ids.take(half)
second = user_ids.drop(half)

p1 = fork do
    first.each do |uid|
        if github.users.key?(uid)
            user = github.users[uid]
            recs = user.recommendations(github)

            if VERBOSE
                user.repos.each { |r| puts r.to_s }
                recs.each { |r| puts r.to_s }
            end
        else
            $stderr.puts "UID #{uid} not found in database ..."
        end
    end
end

p2 = fork do
    second.each do |uid|
        if github.users.key?(uid)
            user = github.users[uid]
            recs = user.recommendations(github)

            if VERBOSE
                user.repos.each { |r| puts r.to_s }
                recs.each { |r| puts r.to_s }
            end
        else
            $stderr.puts "UID #{uid} not found in database ..."
        end
    end
end

Process.waitpid(p1)
Process.waitpid(p2)
