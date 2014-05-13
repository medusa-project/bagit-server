Feature: Version commitment
  In order to make a completed bag available
  As a user
  I want to be able to commit a completed bag

  Background:
    Given the bag with id 'bag' has a version with id 'version'

  Scenario: Committing fails if the version is not in an appropriate state
    Then I cannot commit a version with validation states:
      | unvalidated | invalid | uploading | validating | committed |

  Scenario: I can commit a validated bag
    Given the version with id 'version' for the bag with id 'bag' has validation status 'valid'
    When I post '/bags/bag/versions/version/commit'
    Then the response status should be 200
    And the version with id 'version' for the bag with id 'bag' should have validation status 'committed'

