#!/home/earl/lib/jruby-1.3.1/bin/jruby

require 'hub'

github = Hub.new
github.import_files

# 24690
# 3694   http://github.com/michelsen
# 41849  http://github.com/mighdoll
# 20146
# 43

#uids = [24690, 3694, 41849, 20146, 43]

uids = []

github.users.values.select {|u| u.repos.size < 10 && u.repos.size > 3 }.each do |u|

   uids << u if !u.repos.select { |r| r.name =~ /github\.com$/ }.empty?

end


uids.each do |user|
    #user = github.users[uid]
    puts user.to_s + " watching #{user.repos.size} repos:"
    user.repos.sort_by{ |r| r.name }.each do |r|
        puts "\t#{r}"
        
        unless r.overlaps.empty?
            r.overlaps.sort_by { |o| o.overlap }.reverse[0..10].each do |o|
                puts "\t\t#{o.overlap} users overlap in #{o.repo}"
            end
        end
    end
end
