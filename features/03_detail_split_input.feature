@no-clobber
Feature: split input file: save correct lines to "result.csv and incorrect lines to "error.csv"

  Scenario: check whether the script outputs result files
    Given a file named "sample_data_carriers.csv" with:
      """
      id,carrier_code,flight_number,flight_date
      10008046-0-1-0,TG,7165,2013-08-02
      10008918-0-1-0,DY*,3079,2012-10-26
      10008046-0-1-0,TGD,7165,2013-08-021
      """
    When I run `ruby airparse.rb -f sample_data_carriers.csv -o result.csv -e errors.csv`
    Then the stdout should contain "AirParse processing failed."
    And the file "sample_data_carriers.csv" should exist
    And the file "result.csv" should exist
    And the file "errors.csv" should exist

  Scenario: check whether the script outputs "result.csv" file with correct number of lines
    When I run `bash -c "cat result.csv | wc -l"`
    Then the stdout should contain "3"

  Scenario: check whether the script outputs "error.csv" file with correct number of lines
    When I run `bash -c "cat errors.csv | wc -l"`
    Then the stdout should contain "2"
