Feature: Deletion of bag contents
  In order to maintain the bag
  As a user
  I want to be able to delete files from the bag

  Background:
    Given the bag with id 'test-bag' has a version with id 'test'
    And the version with id 'test' for the bag with id 'test-bag' has contents the fixture 'good-bag'
    And the version with id 'test' for the bag with id 'test-bag' updates its manifest 'manifest-md5.txt'

  Scenario: Delete a top level file
    When I delete '/bags/test-bag/versions/test/contents/bagit.txt'
    Then the response status should be 204
    And the version with id 'test' for the bag with id 'test-bag' should not have content file 'bagit.txt'

  Scenario: Delete a data file
    When I delete '/bags/test-bag/versions/test/contents/data/grass.jpg'
    Then the response status should be 204
    And the version with id 'test' for the bag with id 'test-bag' should not have content file 'data/grass.jpg'

  Scenario: Delete a manifest file
    When I delete '/bags/test-bag/versions/test/contents/manifest-md5.txt'
    Then the response status should be 204
    And the version with id 'test' for the bag with id 'test-bag' should not have content file 'manifest-md5.txt'
    And the version with id 'test' for the bag with id 'test-bag' should not have an 'md5' manifest

  Scenario: Try to delete a file that is not present
    When I delete '/bags/test-bag/versions/test/contents/data/weeds.jpg'
    Then the response status should be 404

  Scenario: Allow deletion from version in certain states
    Then I can delete from a version when in validation states:
      | unvalidated | invalid |

  Scenario: Disallow deletion from version in certain states
    Then I cannot delete from a version when in validation states:
      | valid | validating | uploading | committed |
