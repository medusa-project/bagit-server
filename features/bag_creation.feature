Feature: Bag creation
  In order to submit my content
  As a user
  I want to be able to create a new bag

  Scenario: Create a new bag supplying a version
    When I post '/bags' with JSON fields:
      | id       | version      |
      | test-bag | test-version |
    Then the response status should be 201
    And the response header 'Location' should be '/bags/test-bag/versions/test-version'
    And there should be a bag with id 'test-bag'
    And the bag with id 'test-bag' should have a version with id 'test-version'
    And the content directory should exist for the bag 'test-bag' and version 'test-version'

  Scenario: Create a new bag not supplying a version
    When I post '/bags' with JSON fields:
      | id       |
      | test-bag |
    Then the response status should be 201
    And the response header 'Location' should match '/bags/test-bag'
    And the response header 'Location' should match some uuid
    And there should be a bag with id 'test-bag'
    And the bag with id 'test-bag' should have a version with id some uuid
    And the content directory should exist for the bag 'test-bag' for every version

  Scenario: Try to create a new bag with version already in use
    Given the bag with id 'test-bag' has a version with id 'version'
    When I post '/bags' with JSON fields:
      | id       | version |
      | test-bag | version |
    Then the response status should be 409

  Scenario: Try to create a new bag without supplying an id
    When I post '/bags' with JSON fields:
      | no_id     |
      | something |
    Then the response status should be 400

  Scenario: Try to create a new bag with a blank id
    When I post '/bags' with JSON fields:
      | id |
      |    |
    Then the response status should be 400

