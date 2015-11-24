@no-clobber
Feature: carrier_code should be validated according to IATA/ICAO rules

  # test for bad carrier_code [TGDD]

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


  # test for bad carrier_code [DY**]

  Scenario: check proper carrier_code error detection
    Given a file named "sample_data_carriers.csv" with:
      """
      id,carrier_code,flight_number,flight_date
      10008046-0-1-0,TGD,7165,2013-08-02
      10008918-0-1-0,DY**,3079,2012-10-26
      10008046-0-1-0,TGD,7165,2013-08-21
      """
    When I run `ruby airparse.rb -f sample_data_carriers.csv -o result.csv -e errors.csv`
    Then the stdout should contain "row 3 VALIDATION FAILED"
    And the stdout should contain "field: carrier_code  value: [DY**]  errors"
    And the stdout should contain "value does not match regular expression pattern"
    And the stdout should contain "too long - more than 3 characters"
    And the file "output.csv" should not contain ",DY**,"

  Scenario: additional check whether "output.csv" file does NOT contain the bad carrier_code
    When I run `bash -c "cat output.csv"`
    Then the stdout should not contain ",DY**,"

  Scenario: check whether "error.csv" file contains exactly a single row with the bad carrier_code (plus header)
    When I run `bash -c "cat errors.csv"`
    Then the stdout should contain exactly "id,carrier_code,flight_number,flight_date\n10008918-0-1-0,DY**,3079,2012-10-26"


  # test for multiple bad carrier_code
  Scenario: check proper carrier_code error detection
    Given a file named "sample_data_carriers.csv" with:
      """
      id,carrier_code,flight_number,flight_date
      10008046-0-1-0,TGDA,7165,2013-08-02
      10008918-0-1-0,DY**,3079,2012-10-26
      10008046-0-1-0,T,7165,2013-08-21
      10008046-0-1-0,,7165,2013-08-21
      10008046-0-1-0,OK,7165,2013-08-21
      10008046-0-1-0,NOTOK,7165,2013-08-21
      10008046-0-1-0,N O,7165,2013-08-21
      10008046-0-1-0,NO1,7165,2013-08-21
      """
    When I run `ruby airparse.rb -f sample_data_carriers.csv -o result.csv -e errors.csv`
    Then the stdout should contain "row 2 VALIDATION FAILED"
    And  the stdout should contain "field: carrier_code  value: [TGDA]  errors"
    # value with asterisk longer than 3 chars not allowed
    And  the stdout should contain "row 3 VALIDATION FAILED"
    And  the stdout should contain "field: carrier_code  value: [DY**]  errors"
    # value shorter than 2 chars not allowed
    And  the stdout should contain "row 4 VALIDATION FAILED"
    And  the stdout should contain "field: carrier_code  value: [T]  errors"
    # empty value not allowed
    And  the stdout should contain "row 5 VALIDATION FAILED"
    And  the stdout should contain "field: carrier_code  value: []  errors"
    # value longer than 3 chars not allowed
    And  the stdout should contain "row 7 VALIDATION FAILED"
    And  the stdout should contain "field: carrier_code  value: [NOTOK]  errors"
    # white space inside a value not allowed
    And  the stdout should contain "row 8 VALIDATION FAILED"
    And  the stdout should contain "field: carrier_code  value: [N O]  errors"
    # numeric values not allowed
    And  the stdout should contain "row 9 VALIDATION FAILED"
    And  the stdout should contain "field: carrier_code  value: [NO1]  errors"
    # and so on...


  Scenario: check whether "output.csv" file does NOT contain the bad carrier_code
    When I run `bash -c "cat output.csv"`
    Then the stdout should not contain ",TGDA,"
    And the stdout should not contain ",DY**,"
    And the stdout should not contain ",T,"


  # test for multiple bad carrier_code in a single row

  Scenario: check both proper carrier_code error detection AND date format check
    Given a file named "sample_data_carriers.csv" with:
      """
      id,carrier_code,flight_number,flight_date
      10008046-0-1-0,TGDA,7165,2013-08-02
      10008918-0-1-0,DY*,3079,2012-10-26
      10008046-0-1-0,T,7165,2013-08-211
      10008046-0-1-0,$$,7165,2013-08-211
      """
    When I run `ruby airparse.rb -f sample_data_carriers.csv -o result.csv -e errors.csv`
    Then the stdout should contain "row 2 VALIDATION FAILED"
    And  the stdout should contain "row 4 VALIDATION FAILED"
    And  the stdout should contain "row 5 VALIDATION FAILED"
    And  the stdout should contain "field: carrier_code  value: [TGDA]  errors"
    And  the stdout should contain "field: carrier_code  value: [T]  errors"
    And  the stdout should contain "field: carrier_code  value: [$$]  errors"
    And  the stdout should contain "field: flight_date  value: [2013-08-211]  errors: invalid date"

