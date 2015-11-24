Feature: process command lines switches correctly

  In order to test proper switch handling
  As a developer using Cucumber
  I want to check the following scenarios

  Scenario: to make sure that we are testing the correct version of the artifact, check whether the script is signed with the current build version number
    When I run `ruby airparse.rb -s`
    Then the stdout should contain "AirParse 1.0.2"

  Scenario: check whether script without any input files at least runs without errorcode (just checking for correct ruby, gems and and system env)
    When I run `ruby airparse.rb -s`
    Then the exit status should be 0
