Feature: stress test 1
    In order to make sure that the script will work not only once
    Let's stress test the script by processing the sample csv file 1000 times (about 3 minutes)

  @mtk_stress_test
  # @announce-output
  Scenario: check whether the script works with a sample file
    When I run `ruby airparse.rb -f ../../features/fixtures/sample_data.csv -o result.csv --iters 1000`
    Then the stdout should contain "AirParse processing finished."
    And the stdout should contain "Iteration #1000"
    And the file "result.csv" should exist
    And the file "errors.csv" should exist
