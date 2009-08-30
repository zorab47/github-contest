#!/home/earl/lib/jruby-1.3.1/bin/jruby

$LOAD_PATH << './lib'

require 'progressbar'
require 'hub'

$stdout.sync = true
$hub_verbose = false

github = Hub.new
github.import_files

test = File.new("data/test.txt", "r")

user_ids = []

while (line = test.gets)
    user_ids << line.chomp.to_i
end

user_ids = user_ids.reverse

threads = []

pbar = ProgressBar.new("Recommending", user_ids.size)

until user_ids.empty? do

    if (Thread.list - [Thread.main]).size < 2
        uid = user_ids.pop
        pbar.inc

        threads << Thread.new do

            if github.users.key?(uid)
                user = github.users[uid]
                recs = user.recommendations(github)[0..9]

                puts "#{user.id}:" + recs.collect { |r| r.id }.join(',')

                if $hub_verbose
                    user.repos.each { |r| puts r.to_s }
                    recs.each { |r| puts r.to_s }
                else
                    #$stderr.putc '.'
                end
            else
                #$stderr.puts "UID #{uid} not found in database ..."
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

pbar.finish
