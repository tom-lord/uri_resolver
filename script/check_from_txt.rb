#!/usr/bin/env ruby
# Useage: `./script/check_from_txt.rb <domlist1> <domlist2> <...>
# Where domlist1 etc are simple text files containing 1 domain name on each line - e.g.
#
#   google.com
#   facebook.com
#   github.com

require 'uri_resolver'
require 'fileutils'

# Clear old results, if any
FileUtils.rm_rf "results"
Dir.mkdir('results')

domains_count = {} # memoization

ARGF.each_line do |domain|
  domains_count[ARGF.filename] ||= %x{wc -l #{ARGF.filename}}.split.first.to_i
  if ARGF.file.lineno == 1
    puts "~" * 80
    puts "Resolving domains from #{ARGF.filename}:"
    puts "~" * 80
  end
  print "(#{ARGF.file.lineno}/#{domains_count[ARGF.filename]}) " # Counter
  puts "Checking domain: #{domain}"
  # Strip any new line (\n) characters!
  File.open("results/#{UriResolver.resolve_status(domain.chomp)}.txt", 'a') do |f|
    f.write domain
  end
end

puts "*" * 80
puts "Finished! Check the files in the `results` folder."
puts "(Note that 99% of 'maybe resolves' files do NOT resolve.)"

# This currenlty hangs here for a few seconds.
# TODO: Handle these threads better... I think something must not be getting killed?
# Review how the library works. For example, perhaps using this gem would be an easy solution:
# https://github.com/typhoeus/typhoeus
