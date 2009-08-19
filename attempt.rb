#!/home/earl/lib/jruby-1.3.1/bin/jruby -J-Xmx2000m -J-Xss10m

require 'hub'

$stdout.sync = true
$hub_verbose = false

github = Hub.new
github.import_files

test = File.new("test.txt", "r")

user_ids = []

while (line = test.gets)
    user_ids << line.chomp.to_i
end

#user_ids = user_ids.shuffle

half = (user_ids.size / 2).to_i

first = user_ids[0..half-1]
second = user_ids[half..user_ids.size - 1]

threads = []

threads << Thread.new do
    first.each do |uid|
        if github.users.key?(uid)
            user = github.users[uid]
            recs = user.recommendations(github)

            if $hub_verbose
                user.repos.each { |r| puts r.to_s }
                recs.each { |r| puts r.to_s }
            else
                $stderr.putc '.'
            end
        else
            $stderr.puts "UID #{uid} not found in database ..."
        end
    end
end

threads << Thread.new do
    second.each do |uid|
        if github.users.key?(uid)
            user = github.users[uid]
            recs = user.recommendations(github)

            if $hub_verbose
                user.repos.each { |r| puts r.to_s }
                recs.each { |r| puts r.to_s }
            else
                $stderr.putc '.'
            end
        else
            $stderr.puts "UID #{uid} not found in database ..."
        end
    end
end

threads.each do |thread|
    thread.join
end
