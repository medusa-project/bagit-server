Feature: Version validation
  In order to move a bag version properly through a workflow
  As a user
  I want to be able to track and change a version's validation status

  Background:
    Given the bag with id 'bag' has a version with id 'version'

  Scenario: Retrieve a version's validation status
    When I get '/bags/bag/versions/version/validation'
    Then the response status should be 200
    And the JSON response at "status" should be "unvalidated"