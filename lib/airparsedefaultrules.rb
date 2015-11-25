require_relative 'airparselib'

# Default rules class, implement all your validation/processing logic/classification code here
class AirParseDefaultRules < AirParseLib
  # Set custom headers for output files that are independent of the input file headers
  def initialize
    @output_data_header = "id,carrier_code_type,carrier_code,flight_number,date\n"
    @errors_data_header = "id,carrier_code,flight_number,flight_date\n"
  end


  # current input file model:
  # id,carrier_code,flight_number,flight_date

  # def is_valid_id(value)
  #   true
  # end

  def is_valid_flight_date(value)
    # init
    return_value = { correct: false, reason: [] }

    # rule 1 - check if date is valid ISO8601 format (using standard library Date)
    begin
      # convert an ISO8601 date into UTC
      parsed_date = Date.iso8601(value)
    rescue ArgumentError => exc
      return_value = { correct: false, reason: exc.to_s }
    else
      return_value = { correct: true, reason: [] }
      # ensure
    end

    # rule 2 - check if date is not out of range...

    # validation results are returned as a simple hash like: {correct: false, reason: exc.to_s}
    return_value
  end

  def is_valid_carrier_code(value)
    # init
    return_value = { correct: true, reason: [] }

    # rule 1 - carrier code should contain 2 alphanumeric chracters with optional '*' as a third character
    # OR three alphanumeric characters
    carrier_code_re = /(^[a-zA-Z0-9]{2}[*]{0,1}$)|(^[a-zA-Z]{3}$)/
    unless carrier_code_re.match(value) # if value outside of regex range, fail
      return_value = { correct: false, reason: (return_value[:reason] << 'value does not match regular expression pattern') }
    end

    # redundant rule 2 - fail if string is longer than 3 characters
    if value.length > 3
      return_value = { correct: false, reason: (return_value[:reason] << 'too long - more than 3 characters') }
    end

    # rule 3 - check if carrier_code exists in db...
    # rule 4 - check if carrier is active...

    return_value
  end

  # do nothing sample processor, just return an array with value(s)
  def process_id(value)
    [value]
  end

  def process_carrier_code(value)
    carrier_code_type = nil

    # classify carrier codes
    carrier_code_type = 'IATA' if value =~ /(^[a-zA-Z0-9]{2}[*]{0,1}$)/
    carrier_code_type = 'ICAO' if value =~ /(^[a-zA-Z]{3}$)/

    # values returned from processors are appended to the result line array, in this example, we append additional column before carrier_code
    [carrier_code_type, value]
  end
end
