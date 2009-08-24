##!/home/earl/lib/jruby-1.3.1/bin/jruby -J-Xmx1000m

$LOAD_PATH << './lib'

require 'hub'
require 'set'

$stdout.sync = true
$hub_verbose = true

github = Hub.new
github.import_files

leader_guesses = {}

leader_results = File.new('leader-results.txt', 'r')

while (line = leader_results.gets)
    uid, data = line.chomp.split(':')
    uid = uid.to_i

    repos = data.split(',').collect do |r|
        r.to_i
    end

    leader_guesses[uid] = repos
end

# 24690
# 3694   http://github.com/michelsen
# 41849  http://github.com/mighdoll
# 20146
# 43

#uids = [24690, 3694, 41849, 20146, 43]

uids = []

test_file = File.new('test.txt', 'r')

while (line = test_file.gets)
    uids << line.chomp.to_i
end


uids.sort_by { rand }[0..2].each do |uid|
    user = github.users[uid]
    puts user.to_s + " watching #{user.repos.size} repos:"

    top_repos_from_shared_users = []

    recs = user.recommendations(github) || Set.new
    top_repos_from_shared_users = (user.find_users_with_shared_repos[0..1].collect { |u| (u.repos - user.repos).to_a.sort.reverse[0..9] }.flatten)

    if (recs.size > 10)
        raise "Too many recomendations."
    end

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

    puts "\tLeader:"
    unless leader_guesses[user.id].nil?
        leader_guesses[user.id].each do |rid|
            r = github.repos[rid]

            out = "\t\t"

            if recs.include?(r)
                out += "y"
            else
                out += " "
            end

            out += " #{r}"

            puts out
        end
    else
        puts "\t\tNo guesses."
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
