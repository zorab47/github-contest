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
    records.each_pair do |key, value| 
        puts value
    end
end

github = Hub.new
github.import_repos_from(File.new("repos.txt", "r"))
github.import_langs_from(File.new("lang.txt", "r"))
github.import_users_from(File.new("data.txt", "r"))

active_record = github.repos[273]
show active_record.langs





