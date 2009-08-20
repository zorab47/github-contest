#!/home/earl/lib/jruby-1.3.1/bin/jruby

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

#user_ids = user_ids.sort_by { rand }[0..9]

threads = []

until user_ids.empty? do

    if (Thread.list - [Thread.main]).size < 2
        uid = user_ids.pop

        threads << Thread.new do

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

            # wake the main thread to create a new worker thread
            Thread.main.run

        end

    else
        sleep # until any thread completes
    end

end

threads.each do |thread|
    thread.join
end
