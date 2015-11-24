@no-clobber

Feature: carrier_code should be recognized and marked according to a matching IATA/ICAO abbreviation pattern

  # recognize and mark IATA carrier_code

  Scenario: check proper carrier_code error detection
    Given a file named "sample_data_carriers.csv" with:
      """
      id,carrier_code,flight_number,flight_date
      10008046-0-1-0,TGDD,7165,2013-08-02
      10008918-0-1-0,DY*,3079,2012-10-26
      10008046-0-1-0,TGD,7165,2013-08-21
      """
    When I run `ruby airparse.rb -f sample_data_carriers.csv -o result.csv -e errors.csv`
    Then the stdout should contain "row 2 VALIDATION FAILED"
    And the stdout should contain "field: carrier_code  value: [TGDD]  errors"
    And the stdout should contain "value does not match regular expression pattern"
    And the stdout should contain "too long - more than 3 characters"

  Scenario: check whether "output.csv" file does NOT contain the bad carrier_code
    When I run `bash -c "cat output.csv"`
    Then the stdout should not contain ",TGDD,"

  Scenario: check whether "error.csv" file contains exactly a single row with the bad carrier_code (stripping header)
    When I run `bash -c "cat errors.csv"`
    Then the stdout should contain exactly "id,carrier_code,flight_number,flight_date\n10008046-0-1-0,TGDD,7165,2013-08-02"


  Scenario: recognize and mark ICAO carrier_code
    Given a file named "sample_data_carriers.csv" with:
      """
      id,carrier_code,flight_number,flight_date
      10008046-0-1-0,TGD,7165,2013-08-02
      """
    When I run `ruby airparse.rb -f sample_data_carriers.csv -o result.csv -e errors.csv --verbose`
    Then the stdout should contain "ICAO"
    And the stdout should contain "AirParse processing finished."

  Scenario: recognize and mark IATA* carrier_code
    Given a file named "sample_data_carriers.csv" with:
      """
      id,carrier_code,flight_number,flight_date
      10008046-0-1-0,AB*,7165,2013-08-02
      """
    When I run `ruby airparse.rb -f sample_data_carriers.csv -o result.csv -e errors.csv --verbose`
    Then the stdout should contain "IATA"
    And the stdout should contain "AirParse processing finished."

  Scenario: recognize and mark IATA carrier_code
    Given a file named "sample_data_carriers.csv" with:
      """
      id,carrier_code,flight_number,flight_date
      10008046-0-1-0,TG,7165,2013-08-02
      """
    When I run `ruby airparse.rb -f sample_data_carriers.csv -o result.csv -e errors.csv --verbose`
    Then the stdout should contain "IATA"
    And the stdout should contain "AirParse processing finished."

  #@mtk_working_on
  #@announce-output
  Scenario: recognize and mark ICAO carrier_code, detect bad ICAO code, detect bad dates
    Given a file named "sample_data_carriers.csv" with:
      """
      id,carrier_code,flight_number,flight_date
      10008046-0-1-0,TGD,7165,2013-08-02
      10008046-0-1-0,TG1,7165,2013-08-02
      10008046-0-1-0,TG1,7165,2013-08-211
      """
    When I run `ruby airparse.rb -f sample_data_carriers.csv -o result.csv -e errors.csv --verbose`
    Then the stdout should contain "ICAO"
    And the stdout should contain "AirParse processing failed."
    And the stdout should contain "row 3 VALIDATION FAILED"
    And the stdout should contain "field: carrier_code  value: [TG1]  errors"
    And the stdout should contain "row 3 VALIDATION FAILED"
    And the stdout should contain "field: flight_date  value: [2013-08-211]  errors: invalid date"

