@no-clobber

Feature: CSV should correctly process full csv spec parsing

  Scenario: check proper doublequote handling
    Given a file named "sample_data_carriers.csv" with:
      """
      id,carrier_code,flight_number,flight_date
      "10008046 -0-1-0","TGDD",7165,2013-08-02
      10008918-0-1-0,DY*,3079,2012-10-26
      10008046-0-1-0,"TGD",7165,2013-08-21
      """
    When I run `ruby airparse.rb -f sample_data_carriers.csv -o result.csv -e errors.csv`
    Then the stdout should contain "row 2 VALIDATION FAILED"
    And the stdout should contain "field: carrier_code  value: [TGDD]  errors"
    And the stdout should contain "value does not match regular expression pattern"
    And the stdout should contain "too long - more than 3 characters"


  Scenario: check proper separator (comma) inside value handling
    Given a file named "sample_data_carriers.csv" with:
      """
      id,carrier_code,flight_number,flight_date
      "10008046,-0-1-0","T,GDD",7165,2013-08-02
      10008918-0-1-0,DY*,3079,2012-10-26
      10008046-0-1-0,"TGD",7165,2013-08-21
      """
    When I run `ruby airparse.rb -f sample_data_carriers.csv -o result.csv -e errors.csv`
    Then the stdout should contain "row 2 VALIDATION FAILED"
    And the stdout should contain "field: carrier_code  value: [T,GDD]  errors"
    And the stdout should contain "value does not match regular expression pattern"
    And the stdout should contain "too long - more than 3 characters"

