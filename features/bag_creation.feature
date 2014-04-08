Feature: Bag creation
  In order to submit my content
  As a user
  I want to be able to create a new bag

  Scenario: Create a new bag supplying a version
    When I post to '/bags' with JSON fields:
      | id       | version      |
      | test-bag | test-version |
    Then the response status should be 201
    And the response header 'Location' should be '/bags/test-bag/test-version'
    And there should be a bag with id 'test-bag'
    And the bag with id 'test-bag' should have a version with id 'test-version'
    And the content directory should exist for the bag 'test-bag' and version 'test-version'

  Scenario: Create a new bag not supplying a version
    Given PENDING

  Scenario: Try to create a new bag with version already in use
    Given PENDING

  Scenario: Try to create a new bag without supplying an id
    Given PENDING
