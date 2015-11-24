#!/usr/bin/env ruby

require 'trollop'
require 'csv'
require 'pp'
require 'json'
require 'date'
require 'fileutils'

@opts = Trollop.options do
  version 'AirParse 1.0.2, 2015 Maciej Kompf'
  banner <<-EOS
Airparse is a lighweight csv parser/validator/processor.
It can be used to parse any csv file, validate each value with
a custom validator method. Optionally, each value can be further
processed/formatted before being output to the result file.

Input/output files must be specified as command line params,
custom validators/processors can be defined
in the default lib/airparsedefaultrules.rb file or any user defined file.

Optionally, a different rules file can be specified.

Usage:
       ./airparse.rb [options] --file <filename> --output <filename> [--rules <filename>] [--errors <filename>]

where [options] are:
EOS

  opt :verbose, 'Verbose debug output', default: false
  opt :file, 'CSV filename to parse',
      type: String, required: true
  opt :output, 'output filename',
      type: String, required: true
  opt :errors, 'errors filename',
      type: String, required: false, default: 'errors.csv'
  opt :rules, 'rules Class name (use camelcase, filename containg the specified class should be named after the Class, but lowercase; all rules files must be located within lib/ folder)',
      type: String, required: false, default: 'AirParseDefaultRules'
  opt :iters, 'Number of iterations (for stress testing)', default: 1
  # idea: opt :lint, "Skip lint csv file validation", :default => false
end

# input params validaton
Trollop.die :file, 'must exist' if @opts[:file] && !File.exist?(@opts[:file])
Trollop.die :iters, 'must be non-negative' if @opts[:iters] < 0

# set command line exit status code
Signal.trap('EXIT') { exit 0 }

# load business rules/logic from external file/class
require_relative 'lib/' + @opts[:rules].downcase

# create instance of the AirParse library
airparse = AirParseLib.new

puts "\nAirParse processing started: "
puts '  input file: ' + @opts[:file]
puts '  output file: ' + @opts[:output]
puts '  errors file: ' + @opts[:errors]
puts '  rules file: ' + @opts[:rules]
puts
@airparseresult = false
(1..@opts[:iters]).each do |i|
  puts "Iteration ##{i}"
  @airparseresult = airparse.process(@opts) # call main processing loop with all commandline options
end
if @airparseresult
  puts 'AirParse processing finished.'
else
  puts 'AirParse processing failed.'
end

# require 'my_main'
# MyMain.new(ARGV.dup).execute!
