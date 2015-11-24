@no-clobber
Feature: dates should be validated according to ISO8601

  # bad date test [2013-08-021]

  Scenario: check proper ISO8601 error detection [2013-08-021]
    Given a file named "sample_data_carriers.csv" with:
      """
      id,carrier_code,flight_number,flight_date
      10008046-0-1-0,TG,7165,2013-08-02
      10008918-0-1-0,DY*,3079,2012-10-26
      10008046-0-1-0,TGD,7165,2013-08-021
      """
    When I run `ruby airparse.rb -f sample_data_carriers.csv -o result.csv -e errors.csv`
    Then the stdout should contain "row 4 VALIDATION FAILED"
    And the stdout should contain "[2013-08-021]  errors: invalid date"

  Scenario: check whether "output.csv" file does NOT contain the bad date
    When I run `bash -c "cat output.csv"`
    Then the stdout should not contain "2013-08-021"

  Scenario: check whether "error.csv" file contains exactly a single row with the bad date (plus header)
    When I run `bash -c "cat errors.csv"`
    Then the stdout should contain exactly "id,carrier_code,flight_number,flight_date\n10008046-0-1-0,TGD,7165,2013-08-021"



  # bad date test [12/12/12]

  Scenario: check proper ISO8601 error detection [12/12/12]
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

  Scenario: check whether "output.csv" file does NOT contain the bad date
    When I run `bash -c "cat output.csv"`
    Then the stdout should not contain "12/12/12"

  Scenario: check whether "error.csv" file contains exactly a single row with the bad date (stripping header)
    When I run `bash -c "tail -n +2 errors.csv"`
    Then the stdout should contain exactly "10008046-0-1-0,TG,7165,12/12/12"


  # bad date test [multiple date errors]

  Scenario: check proper ISO8601 error detection [multiple date errors]
    Given a file named "sample_data_carriers.csv" with:
      """
      id,carrier_code,flight_number,flight_date
      10008046-0-1-0,TG,7165,12/12/12
      10008918-0-1-0,DY*,3079,2012-10-26
      10008046-0-1-0,TGD,7165,2013-08-021
      """
    When I run `ruby airparse.rb -f sample_data_carriers.csv -o result.csv -e errors.csv`
    Then the stdout should contain "row 2 VALIDATION FAILED"
    And the stdout should contain "row 4 VALIDATION FAILED"
    And the stdout should contain "[12/12/12]  errors: invalid date"
    And the stdout should contain "[2013-08-021]  errors: invalid date"

  Scenario: check whether "output.csv" file does NOT contain the bad dates
    When I run `bash -c "cat output.csv"`
    Then the stdout should not contain "12/12/12"
    And the stdout should not contain "2013-08-021"

  Scenario: check whether "error.csv" file contains exactly two rows with the bad dates (stripping header)
    When I run `bash -c "tail -n +2 errors.csv"`
    Then the stdout should contain exactly "10008046-0-1-0,TG,7165,12/12/12\n10008046-0-1-0,TGD,7165,2013-08-021"
