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

puts " ... done."

uids = [1477, 4242, 981, 7203, 34174]

uids.each do |uid|
    u = github.users[uid]
    puts "#{u}: " + u.guesses_by_favorite_lang_and_percentage_of_lang.join(",")
end
