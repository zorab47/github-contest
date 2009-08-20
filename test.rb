#!/home/earl/lib/jruby-1.3.1/bin/jruby

$LOAD_PATH << './lib'

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


uids.sort_by { rand }[0..9].each do |user|
    puts user.to_s + " watching #{user.repos.size} repos:"

    recs = []
    top_repos_from_shared_users = []

    recs = user.recommendations(github)[0..9]
    top_repos_from_shared_users = (user.find_users_with_shared_repos[0..1].collect { |u| (u.repos - user.repos).sort.reverse[0..9] }.flatten)

    puts "\tWatching: "
    user.repos.each do |r|
        puts "\t#{r}"
    end

    puts "\tUsers: "
    user.find_users_with_shared_repos[0..1].each do |u|

        puts "\t\t#{u} (watching #{u.repos.size} repos) is sharing " + u.repos.select { |r| user.repos.collect { |s| s.id }.include?(r.id) }.size.to_s

        (u.repos - user.repos).sort.reverse[0..9].each do |r|
            out = "\t\t\t"
            if recs.include?(r)
                out += "x" 
            else
                out += " "
            end
            out += "  #{r}"

            puts out
        end

    end

    puts "\tOverlapping from watchers: "
    user.overlapping_repos_from_users_with_shared_repos[0..9].each do |r|
        out = "\t\t"
        if recs.include?(r)
            out += "x" 
        else
            out += " "
        end
        out += " #{r}"

        puts out
    end

    puts "\tRecommendations: "
    recs.each do |r|
        out = "\t\t"

        if top_repos_from_shared_users.include?(r)
            out += "x" 
        else
            out += " "
        end

        out += " #{r}"
        
        puts out
    end

    puts "\n\n"
    # user.repos.sort_by{ |r| r.name }.each do |r|
    #     puts "\t#{r}"
    #     
    #     unless r.overlaps.empty?
    #         r.overlaps.sort_by { |o| o.overlap }.reverse[0..10].each do |o|
    #             puts "\t\t#{o.overlap} users overlap in #{o.repo}"
    #         end
    #     end
    # end
end
