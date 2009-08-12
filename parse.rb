#!/usr/bin/ruby

Object.send :undef_method, :id

require 'date'
require 'lang'
require 'repo'
require 'user'
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
github.import_repos_from(File.new("repos.txt", "r"))
github.import_langs_from(File.new("lang.txt", "r"))
github.import_users_from(File.new("data.txt", "r"))

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





