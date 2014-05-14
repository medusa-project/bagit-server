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

  Scenario: Validate a good bag
    Given the version with id 'version' for the bag with id 'bag' has contents the fixture 'good-bag'
    When I post '/bags/bag/versions/version/validate'
    Then the response status should be 200
    When I get '/bags/bag/versions/version/validation'
    Then the response status should be 200
    And the JSON response at "status" should be "valid"
    And the JSON at "errors" should be []

  Scenario: Validate an incomplete bag
    Given the version with id 'version' for the bag with id 'bag' has contents the fixture 'incomplete-bag'
    When I post '/bags/bag/versions/version/validate'
    Then the response status should be 200
    When I get '/bags/bag/versions/version/validation'
    Then the response status should be 200
    And the JSON response at "status" should be "invalid"
    And the JSON at "errors" should be ["data/grass.jpg is manifested but not present"]

  Scenario: Validate an inconsistent bag
    Given the version with id 'version' for the bag with id 'bag' has contents the fixture 'inconsistent-bag'
    When I post '/bags/bag/versions/version/validate'
    Then the response status should be 200
    When I get '/bags/bag/versions/version/validation'
    Then the response status should be 200
    And the JSON response at "status" should be "invalid"
    And the JSON at "errors" should be ["expected data/text/some-text.txt to have Digest::MD5: d4cc995d861474e7c17d7c526b3c0caa, actual is 2b339c5672a32368a4df5fc51723e27b"]

  Scenario: Validation fails if the version is not in an appropriate state
    Then I cannot validate the version with id 'version' for the bag with id 'bag' when in validation states:
      | valid | validating | uploading | committed |
