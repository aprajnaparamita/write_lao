#!/usr/bin/env ruby
# frozen_string_literal: true

# Script to extract vocab examples from course.json and split into files
# Each line format: "#{word_number}#{a_or_b}.#{example_text}"
# Files are split when content exceeds 2900 characters

require 'json'
require 'fileutils'

# Configuration
COURSE_JSON_PATH = File.expand_path('../../../assets/vocab/course.json', __FILE__)
OUTPUT_DIR = File.expand_path('examples', __dir__)
MAX_CHARS = 2490

def extract_word_number(word_id)
  # word_id format: "w_XXXX" where XXXX is the word number (1-500)
  match = word_id.match(/w_(\d+)/)
  match ? match[1].to_i : nil
end

def main
  puts "Reading course data from: #{COURSE_JSON_PATH}"
  course_data = JSON.parse(File.read(COURSE_JSON_PATH))
  words = course_data['words']

  puts "Found #{words.length} words"
  FileUtils.mkdir_p(OUTPUT_DIR)

  current_chunk = ""
  beginning_word_number = nil
  file_index = 1

  words.each do |word|
    word_number = extract_word_number(word['word_id'])
    next unless word_number

    examples = word['examples'] || []
    examples.each_with_index do |example, idx|
      # Only process examples 1 and 2 (index 0 and 1)
      break if idx >= 2
      
      example_letter = idx == 0 ? 'a' : 'b'
      example_text = (example['lao_script'] || '').gsub(/\s+/, '')
      
      line = "#{word_number}#{example_letter}.#{example_text}\n"
      
      # Check if adding this line would exceed the limit
      if current_chunk.length + line.length > MAX_CHARS && current_chunk.length > 0
        # Write current chunk to file
        filename = "#{beginning_word_number}_#{word_number - 1}.txt"
        filepath = File.join(OUTPUT_DIR, filename)
        File.write(filepath, current_chunk)
        puts "Wrote #{filepath} (#{current_chunk.length} chars, words #{beginning_word_number}-#{word_number - 1})"
        
        file_index += 1
        current_chunk = ""
        beginning_word_number = nil
      end
      
      # Start a new chunk if needed
      if beginning_word_number.nil?
        beginning_word_number = word_number
      end
      
      current_chunk += line
    end
  end

  # Write remaining content
  if current_chunk.length > 0
    # Get the last word number from the chunk
    last_line = current_chunk.lines.last
    last_word_number = last_line&.split('.')&.first&.to_i
    
    if beginning_word_number && last_word_number
      filename = "#{beginning_word_number}_#{last_word_number}.txt"
      filepath = File.join(OUTPUT_DIR, filename)
      File.write(filepath, current_chunk)
      puts "Wrote #{filepath} (#{current_chunk.length} chars, words #{beginning_word_number}-#{last_word_number})"
    end
  end

  puts "Done! Created #{file_index} file(s) in #{OUTPUT_DIR}"
end

main
