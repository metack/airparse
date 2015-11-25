require 'csv'
require 'fileutils'

# Main library class with a single usable method now -> process
class AirParseLib
  # Allows to set custom headers for output files that are independent of the input file headers
  attr_accessor :output_data_header, :errors_data_header
  def initialize
    @output_data_header = "\n"
    @errors_data_header = "\n"
  end

  # Processes csv file passed with optional rules class to produce result and error output
  #
  # @opts format [Hash] the format type, `:text` or `:html`
  # @param [Hash] opts the options to process a csv file
  # @option opts [String] :file CSV filename to parse
  # @option opts [String] :output output filename
  # @option opts [String] :errors errors filename
  # @option opts [String] :rules rules Class name (use camelcase, filename containg the specified class
  #                              should be named after the Class, but lowercase; all rules files must be
  #                              located within lib/ folder), default: 'AirParseDefaultRules'
  # @return [Boolean] true if processed with success, false otherwise
  def process(opts)
    # create specific AirParse instance from rules file specified on commandline

    # some meta hacks
    mtk_rules_file = opts[:rules]
    mtk_rules_file_sym = mtk_rules_file.to_sym
    mtk_rules_file_sym_klass = Kernel.const_get(mtk_rules_file_sym) # to use Class with a name passed as string
    parser = mtk_rules_file_sym_klass.new # from this moment, parser is a normal class instance with our custom rules loaded

    # prepare output files

    ## if they exist, remove output files before processing
    [opts[:errors], opts[:output]].each do |e|
      if File.exist?(e)
        puts 'removing file: ' + e
        FileUtils.rm(e)
      end
    end
    ## write headers to output files, an output/error csv headers are specified in custom rules file/class
    File.open(opts[:output], 'w') { |f| f.write(parser.output_data_header) }
    File.open(opts[:errors], 'w') { |f| f.write(parser.errors_data_header) }

    ct = 0 # processed line counter
    @mtkfailreasons = [] # an array with all cumulated errors found in a processed line
    @air_model = [] # an array with input file column names

    # open(opts[:file]) do |csv|
    # csv.each_line do |line|
    CSV.foreach(opts[:file], headers: false) do |values|
      ct += 1

      # old 3 lines, before CSV.foreach, so parse method is obsolete now
      # parse current line
      # values = parser.parse(line)

      # read line 1 with csv header to model array;
      # we assume, that the first line of the csv file contains header with proper field names
      # the names must be matched by validator and processors defined in AirParseClasifyAirlineCodes
      if ct == 1
        @air_model = values # read parsed column names from header into model
      else # for all remaining lines
        if opts[:verbose]
          puts "\nprocessing:"
          pp values
        end

        # business rules validation
        validation = { correct: true, reason: [] } # we assume correct validation results
        @mtkfailreasons = [] # an array with all cumulated errors found in a processed line

        # rule: numbers of data fields should eq to number of header/model variables
        if values.length != @air_model.length
          validation = { correct: false, reason: [] }

          @mtkfailreasons << ('incorrect number of columns: ' << values.length.to_s << ' instead of ' << @air_model.length.to_s)
        end

        data_output = []
        error_output = []
        if validation[:correct]
          data_output = []
          error_output = []
          cti = 0 # current field counter

          # process each value in a line
          values.each do |value|
            value = '' if value.nil? # change nil to empty string, we don't like nils in output csv
            # step 1. input data validation
            # =============================

            # a validator method name is constructed from processed values' field name
            dynamic_validator_mehod_name = 'is_valid_' + @air_model[cti]
            puts 'calling validator: ' + dynamic_validator_mehod_name if opts[:verbose]

            # call a proper validator method for each value
            if parser.respond_to?(dynamic_validator_mehod_name.to_sym) # check if custom validator is defined in AirParseClassifyAirlineCodes class
              validation = parser.send(dynamic_validator_mehod_name, value)
            else # if no custom validator defined, we must assume correct result, so that the field/line will be output unchanged
              validation = { correct: true, reason: [] }
            end

            puts 'row validation results: ' + validation.to_json if opts[:verbose]

            # process field validation results
            unless validation[:correct] # if validation failed
              if validation[:reason] # if exists, add detailed validation result description to row validation results array
                @mtkfailreasons << ('field: ' << @air_model[cti] << '  value: [' + value + ']' << '  errors: ' << validation[:reason].to_s)
              end
            end

            # step 2. if validation correct, process the data
            # ===============================================

            if validation[:correct] # if validation succeeded

              # a processor method name is constructed from processed values' field name
              dynamic_processor_mehod_name = 'process_' + @air_model[cti]

              # call a proper processor method for each value
              if parser.respond_to?(dynamic_processor_mehod_name.to_sym) # check if custom processor is defined in AirParseClassifyAirlineCodes class
                puts 'calling processor: ' + dynamic_processor_mehod_name if opts[:verbose]

                # call custom processor
                data_output_result = parser.send(dynamic_processor_mehod_name, value)
                puts 'processed result: ' + data_output_result.to_s if opts[:verbose]

                data_output_result.each { |e| data_output << e }

              else # if no custom processor defined, we return field value unchanged
                data_output << value
              end
            end # data processing

            error_output << value

            cti += 1 # let's move to the next field to be processed
          end # values.each
        end # if validation correct

        if @mtkfailreasons == [] # no errors during validation/processing
          # all fields in a line have been processed, so append the result line to result file
          File.open(opts[:output], 'a') { |f| f.write(data_output.to_csv) }
        else # error(s) found
          puts
          puts 'row ' + ct.to_s + ' VALIDATION FAILED'
          puts @mtkfailreasons
          puts
          # append bad csv line to the error file
          File.open(opts[:errors], 'a') { |f| f.write(error_output.to_csv) }
          # TODO: if output errors desc to result file
          # File.open('errors.csv', 'a') {|f| f.write("row "+ct.to_s+' VALIDATION FAILED'+"\n"+@mtkfailreasons.to_s+"\n\n") }
        end
      end
      # end # csv.each_line do |line|
    end # do csv
    # return true if no fail reasons
    @mtkfailreasons == []
  end
end


__END__

  # below is for future expansion / reference only, ignore it

  # def initialize(argv, stdin=STDIN, stdout=STDOUT, stderr=STDERR, kernel=Kernel)
  #   @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
  # end

  # def execute!
  #   # your code here, assign a value to exitstatus
  #   @kernel.exit(exitstatus)
  # end

  # Parses csv line
  #
  # @param [String] line a csv line to split into array
  # @return [Array] containing separated items

  # def parse(line)
  #   values = line.delete("\n").split(',') # strip new line character (if exists), split csv columns into fields
  #   values # returns line values as an array
  # end
