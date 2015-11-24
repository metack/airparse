#!/usr/bin/env ruby

require_relative 'lib/airparselib'

@opts = {
  verbose: false,
  file: 'sample_data.csv',
  output: 'output.csv',
  errors: 'errors.csv',
  rules: 'AirParseDefaultRules'
}

# load business rules/logic from external file/class
require_relative 'lib/' + @opts[:rules].downcase

airparse = AirParseLib.new

airparseresult = airparse.process(@opts) # call main processing loop with all options
if airparseresult
  puts 'AirParse processing finished.'
else
  puts 'AirParse processing failed.'
end
