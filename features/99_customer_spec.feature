@no-clobber
Feature: test with the Customer Specification

  In order to deliver a complete solution
  As a developer using BDD who tests not only the general quality of the code,
  But also checks the completeness of the specification fulfilment
  I want to make sure that all of the following customer requirements are met

# Command line interface:
  Scenario: 1.1 Command line must accept a file path of the input file to process.
    Given a file named "sample_data_carriers.csv" with:
      """
      id,carrier_code,flight_number,flight_date
      10008046-0-1-0,TG,7165,2013-08-02
      """
    When I run `ruby airparse.rb -o result.csv`
    Then the stderr should contain "Error: option --file must be specified."
    When I run `ruby airparse.rb -f sample_data_carriers.csv -o result.csv`
    Then the stdout should contain "input file: sample_data_carriers.csv"

  Scenario: 1.2 Command line must accept a file path of the output file to generate.
    When I run `ruby airparse.rb -f sample_data_carriers.csv`
    Then the stderr should contain "Error: option --output must be specified."
    When I run `ruby airparse.rb -f sample_data_carriers.csv -o result.csv`
    Then the stdout should contain "output file: result.csv"

  Scenario: 1.3 Command line must be user-friendly to the degree required for an internal tool. The tool should handle errors with the input file.
    When I run `ruby airparse.rb -h`
    Then the stdout should contain "Usage:"
    When I run `ruby airparse.rb -f missing.csv -o result.csv`
    Then the stderr should contain "Error: argument --file must exist."

# Input file specification:
  Scenario: 1.4 CSV file with the following headings: id, carrier_code, flight_number, flight_date First line is the header, all subsequent lines are data
    When I run `ruby airparse.rb -f sample_data_carriers.csv -o result.csv`
    Then the stdout should contain "AirParse processing finished."
    When I run `bash -c "head -n1 sample_data_carriers.csv"`
    Then the stdout should contain "id,carrier_code,flight_number,flight_date"

  Scenario: 1.5 All fields are required
    Given a file named "sample_data_carriers.csv" with:
      """
      id,carrier_code,flight_number,flight_date
      10008046-0-1-0,TG,7165,2013-08-02
      10008047-0-1-0,TG,7163
      10008048-0-1-0,7165,2013-08-02
      """
    When I run `ruby airparse.rb -f sample_data_carriers.csv -o result.csv`
    Then the stdout should contain "row 3 VALIDATION FAILED"
    And the stdout should contain "incorrect number of columns: 3 instead of 4"

  Scenario: 1.6 The date field contains an ISO 8601 formatted date
    Given a file named "sample_data_carriers.csv" with:
      """
      id,carrier_code,flight_number,flight_date
      10008046-0-1-0,TG,7165,12/12/12
      10008918-0-1-0,DY*,3079,2012-10-26
      10008046-0-1-0,TGD,7165,2013-08-21
      """
    When I run `ruby airparse.rb -f sample_data_carriers.csv -o result.csv -e errors.csv`
    Then the stdout should contain "row 2 VALIDATION FAILED"
    And the stdout should contain "[12/12/12]  errors: invalid date"

# Output file specification:
  Scenario: 1.7 Output a CSV file with the following headings: id, carrier_code_type, carrier_code, flight_number, date
    When I run `ruby airparse.rb -f sample_data_carriers.csv -o result.csv`
    Then the stdout should contain "AirParse processing finished."
    When I run `bash -c "head -n1 result.csv"`

    Then the stdout should contain "id,carrier_code_type,carrier_code,flight_number,date"

  #@mtk_working_on
  #@announce-output
  Scenario: 1.8 The only new data is carrier_code_type, the rest of the data is the same as the input
    Given a file named "sample_data_carriers.csv" with:
      """
      id,carrier_code,flight_number,flight_date
      10008046-0-1-0,TG,7165,2014-01-02
      """
    When I run `ruby airparse.rb -f sample_data_carriers.csv -o result.csv -e errors.csv`
    Then the stdout should contain "AirParse processing finished."

  Scenario: check whether "output.csv" file does contains correct data
    When I run `bash -c "cat result.csv"`
    Then the stdout should contain "10008046-0-1-0,IATA,TG,7165,2014-01-02"

  # Valid carrier_code_type values are: ICAO and IATA. See below for details on how to classify carrier codes.
  # Identifying carrier code types:

  Scenario: 1.9 IATA codes are 2 character alphanumeric codes that identify an airline. They are not unique and can be shared by carriers that are unlikely to operate in the same regions. Controlled duplicates are indicated with an asterisk (*) after the carrier code for a total of 3 characters.
    Given a file named "sample_data_carriers.csv" with:
      """
      id,carrier_code,flight_number,flight_date
      10008046-0-1-0,TG,7165,2013-08-02
      10008918-0-1-0,DY*,3079,2012-10-26
      10008046-0-1-0,TGD*,7165,2013-08-21
      10008046-0-1-0,T1,7165,2013-08-21
      """
    When I run `ruby airparse.rb -f sample_data_carriers.csv -o result.csv -e errors.csv`
    Then the stdout should contain "row 4 VALIDATION FAILED"
    And the stdout should contain "field: carrier_code  value: [TGD*]  errors"
    And the stdout should contain "value does not match regular expression pattern"
    And the stdout should contain "too long - more than 3 characters"


  Scenario: 1.10 ICAO codes are 3 character alphabetic codes that identify an airline. They are unique.
    Given a file named "sample_data_carriers.csv" with:
      """
      id,carrier_code,flight_number,flight_date
      10008046-0-1-0,TGA,7165,2013-08-02
      10008918-0-1-0,DY1,3079,2012-10-26
      10008046-0-1-0,TGD*,7165,2013-08-21
      """
    When I run `ruby airparse.rb -f sample_data_carriers.csv -o result.csv -e errors.csv`
    Then the stdout should contain "row 3 VALIDATION FAILED"
    And the stdout should contain "field: carrier_code  value: [DY1]  errors"
    And the stdout should contain "value does not match regular expression pattern"
    And the stdout should contain "field: carrier_code  value: [TGD*]  errors"
    And the stdout should contain "too long - more than 3 characters"

# Invalid entries:
  # @announce-stdout
  Scenario: 1.11 Invalid entries should be written to an error.csv file Invalid entries should not be written to the output file
    Given a file named "sample_data_carriers.csv" with:
      """
      id,carrier_code,flight_number,flight_date
      10008046-0-1-0,TG,7165,12/12/12
      10008918-0-1-0,DY*,3079,2012-10-26
      10008046-0-1-0,TGD,7165,2013-08-21
      10008047-0-1-0,TGD*,7165,2013-08-21
      """
    When I run `ruby airparse.rb -f sample_data_carriers.csv -o result.csv -e errors.csv`
    Then the stdout should contain "row 2 VALIDATION FAILED"
    And the stdout should contain "[12/12/12]  errors: invalid date"

  Scenario: check whether "result.csv" file does NOT contain the bad date AND the bad carrier_code entry
    When I run `bash -c "cat result.csv"`
    Then the stdout should not contain "12/12/12"
    And the stdout should not contain "TGD*"

  Scenario: check whether "error.csv" file contains exactly a two rows with the bad date and code (stripping header)
    When I run `bash -c "tail -n +2 errors.csv"`
    Then the stdout should contain exactly "10008046-0-1-0,TG,7165,12/12/12\n10008047-0-1-0,TGD*,7165,2013-08-21"


# Sample data:
  ## check operation with the complete sample file (fixture)
  Scenario: 1.12 Sample data for the tool: File:Sample data.csv.zip
    When I run `ruby airparse.rb -f ../../features/fixtures/sample_data.csv -o result.csv -e errors.csv`
    Then the stdout should contain "row 23 VALIDATION FAILED"
    And the stdout should contain "field: carrier_code  value: [SQ**]  errors"
    And the stdout should contain "field: flight_date  value: [2013/08-03]  errors: invalid date"
    And the stdout should contain "row 25 VALIDATION FAILED"
    And the stdout should contain "field: carrier_code  value: [SKAB]  errors"
    And the stdout should contain "row 26 VALIDATION FAILED"
    And the stdout should contain "field: carrier_code  value: [M]  errors"
    And the stdout should contain "row 27 VALIDATION FAILED"
    And the stdout should contain "field: carrier_code  value: [ZI12]  errors"
    And the stdout should contain "row 28 VALIDATION FAILED"
    And the stdout should contain "field: carrier_code  value: [AC**]  errors"
    And the stdout should contain "row 434 VALIDATION FAILED"
    And the stdout should contain "field: flight_date  value: [12/11/2012]  errors: invalid date"
    And the stdout should contain "row 562 VALIDATION FAILED"
    And the stdout should contain "field: flight_date  value: [2012-0910]  errors: invalid date"
    And the stdout should contain "row 701 VALIDATION FAILED"
    And the stdout should contain "field: flight_date  value: [22-03-2013]  errors: invalid date"



# This feature file is only a general requirements check, for detailed technical scenarios, look into other '*_detail_*.feature' files
