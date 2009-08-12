#!/usr/bin/ruby

Object.send :undef_method, :id

require 'hub'

def parse_data_line(line)
    line.chomp.split(":")
end

def parse_data_file(users)
  data = File.new("data.txt", "r")

  while (line = data.gets)
    user_id,repo_id = parse_data_line(line)
    users[user_id] ||= { :repos => [] }
    users[user_id][:repos] << repo_id.to_i
  end
end

def show(records)
    records.each do |record| 
        puts record
    end
end

github = Hub.new
github.import_files

#github.users[1477].repos.each do |repo|
#    puts repo
#    puts "Uses langs: "
#    repo.langs.each do |lang|
#        puts lang
#    end
#end

#github.find_lang("Ruby").repos_sorted_by_popularity.each do |r|
#    puts "#{r.watchers.size} watching #{r}"
#end

  def get_language_usages(user)
      puts "getting langauge"
      languages = []

      user.repos.each do |r|
          puts "\t#{r}"
          r.langs.each do |l|
              puts "\t\t#{l}"
              languages << l
          end
      end

      languages
  end

user = github.users[1477]

puts "Favorite lang for #{user}:" + user.favorite_language.to_s
puts "Top repos for that lang:"  
user.top_repos_by_favorite_lang.each do |r|
    puts "\t#{r}"
end


user = github.users[4242]

puts "Favorite lang for #{user}:" + user.favorite_language.to_s
puts "Top repos for that lang:"  
user.top_repos_by_favorite_lang.each do |r|
    puts "\t#{r}"
end


