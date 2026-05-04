#!/usr/bin/env ruby

i = 1
File.read("word_list.txt").strip.split(" ").each do |word|
  puts "#{i}. \"#{word}\""
  i += 1
end
