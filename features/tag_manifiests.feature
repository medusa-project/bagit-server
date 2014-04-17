Feature: Tag manifest management
  In order to maintain the integrity of tag files
  As the system
  I want to use tag manifests

  Background:
    Given the bag with id 'bag' has a version with id 'version'
    Given the version with id 'version' for the bag with id 'bag' already has files from fixture 'tag-bag':
      | bagit.txt | bag-info.txt |

  Scenario: Upload tag manifest file
    Given PENDING
    Given the version with id 'test' for the bag with id 'test-bag' already has files from fixture 'good-bag':
      | bagit.txt | bag-info.txt |
    When I put '/bags/test-bag/versions/test/contents/manifest-md5.txt' using file 'manifest-md5.txt' from fixture 'good-bag'
    Then the response status should be 201
    And the version with id 'test' for the bag with id 'test-bag' should have content file 'manifest-md5.txt'
    And the version with id 'test' for the bag with id 'test-bag' should have an 'md5' manifest with 2 files

  Scenario: Initially upload invalid tag manifest file
    Given PENDING
    Given the version with id 'test' for the bag with id 'test-bag' already has files from fixture 'good-bag':
      | bagit.txt | bag-info.txt |
    When I put '/bags/test-bag/versions/test/contents/manifest-md5.txt' using file 'bag-info.txt' from fixture 'good-bag'
    Then the response status should be 400
    And the version with id 'test' for the bag with id 'test-bag' should not have content file 'manifest-md5.txt'
    And the version with id 'test' for the bag with id 'test-bag' should not have an 'md5' manifest

  Scenario: Try to upload invalid tag manifest file over valid tag manifest file
    Given PENDING
    Given the version with id 'test' for the bag with id 'test-bag' already has files from fixture 'good-bag':
      | bagit.txt | bag-info.txt | manifest-md5.txt |
    And the version with id 'test' for the bag with id 'test-bag' updates its manifest 'manifest-md5.txt'
    When I put '/bags/test-bag/versions/test/contents/manifest-md5.txt' using file 'bag-info.txt' from fixture 'good-bag'
    Then the response status should be 400
    And the version with id 'test' for the bag with id 'test-bag' should have content file 'manifest-md5.txt'
    And the version with id 'test' for the bag with id 'test-bag' should have an 'md5' manifest with 2 files

  Scenario: Try to upload tag file with incorrect checksum
    Given PENDING
    Given the version with id 'test' for the bag with id 'test-bag' already has files from fixture 'good-bag':
      | bagit.txt | bag-info.txt | manifest-md5.txt |
    And the version with id 'test' for the bag with id 'test-bag' updates its manifest 'manifest-md5.txt'
    When I put '/bags/test-bag/versions/test/contents/data/grass.jpg' using file 'bagit.txt' from fixture 'good-bag'
    Then the response status should be 400
    And the version with id 'test' for the bag with id 'test-bag' should not have content file 'data/grass.jpg'

  Scenario: Upload tag file not in a manifest (unlike content, this works)
    Given PENDING
    Given the version with id 'test' for the bag with id 'test-bag' already has files from fixture 'good-bag':
      | bagit.txt | bag-info.txt | manifest-md5.txt |
    And the version with id 'test' for the bag with id 'test-bag' updates its manifest 'manifest-md5.txt'
    When I put '/bags/test-bag/versions/test/contents/data/weeds.jpg' using file 'data/grass.jpg' from fixture 'good-bag'
    Then the response status should be 400
    And the version with id 'test' for the bag with id 'test-bag' should not have content file 'data/weeds.jpg'
