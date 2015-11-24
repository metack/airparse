@no-clobber
Feature: process command line params properly and generally runs with sample csv file

  Scenario: check whether the script properly parses input params
    When I run `ruby airparse.rb -f ../../features/fixtures/sample_data.csv -o result.csv`
    Then the file "../../features/fixtures/sample_data.csv" should exist
    And the stdout should contain "AirParse processing started:"
    And the stdout should contain "input file: ../../features/fixtures/sample_data.csv"
    And the stdout should contain "output file: result.csv"
    And the stdout should contain "errors file: errors.csv"
    And the stdout should contain "rules file: AirParseDefaultRules"
    And the stdout should contain "AirParse processing finished."
    And the file "result.csv" should exist
    And the file "errors.csv" should exist


  Scenario: check that 'norules.rb' allows for non-processing -> pass input to output without change
    When I run `ruby airparse.rb -f ../../features/fixtures/sample_data.csv -o result.csv -e errors.csv -r NoRules`
    Then the stdout should contain "rules file: NoRules"
    And the stdout should contain "AirParse processing finished."
    And the file "result.csv" should exist
    And the file "errors.csv" should exist
    # we must strip the header because output header is slightly different (date column)
    When I run `bash -c "tail -n +2 ../../features/fixtures/sample_data.csv > nohead_input.csv"`
    When I run `bash -c "tail -n +2 result.csv > nohead_result.csv"`
    Then the file "nohead_input.csv" should be equal to file "nohead_result.csv"
    # ... and the file "errors.csv" should contain only a single header line
