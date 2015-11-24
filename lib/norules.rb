require_relative 'airparselib'

# Default rules class, implement all your custom validators / processors here
class NoRules < AirParseLib
  def initialize
    @output_data_header = "id,email,phone\n"
    @errors_data_header = "id,email,phone\n"
  end

  # do nothing sample validator, just return an array with value(s)

  # def is_valid_id(value)
  #   true
  # end

  # do nothing sample processor, just return an array with value(s)

  # def process_id(value)
  #   [value]
  # end
end
