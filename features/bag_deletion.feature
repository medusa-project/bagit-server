Feature: Bag deletion
  In order to remove bags that are no longer needed
  As a user
  I want to be able to delete bags

  Scenario: Delete a bag
    Given the bag with id 'test-bag' has a version with id 'version'
    When I delete 'bags/test-bag'
    Then the response status should be 200
    And there should not be a bag with id 'test-bag'
    And there should be 0 versions
    And the content_directory should be empty

  Scenario: Try to delete a bag that does not exist
    When I delete 'bags/test-bag'
    Then the response status should be 404