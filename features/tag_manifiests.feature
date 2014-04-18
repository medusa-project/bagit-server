Feature: Tag manifest management
  In order to maintain the integrity of tag files
  As the system
  I want to use tag manifests

  Background:
    Given the bag with id 'bag' has a version with id 'version'
    Given the version with id 'version' for the bag with id 'bag' already has files from fixture 'tag-bag':
      | bagit.txt | bag-info.txt |

  Scenario: Upload tag manifest file
    When I put '/bags/bag/versions/version/contents/tagmanifest-md5.txt' using file 'tagmanifest-md5.txt' from fixture 'tag-bag'
    Then the response status should be 201
    And the version with id 'version' for the bag with id 'bag' should have content file 'tagmanifest-md5.txt'
    And the version with id 'version' for the bag with id 'bag' should have an 'md5' tag manifest with 5 files

  Scenario: Initially upload invalid tag manifest file
    When I put '/bags/bag/versions/version/contents/tagmanifest-md5.txt' using file 'bag-info.txt' from fixture 'tag-bag'
    Then the response status should be 400
    And the version with id 'test' for the bag with id 'test-bag' should not have content file 'tagmanifest-md5.txt'
    And the version with id 'test' for the bag with id 'test-bag' should not have an 'md5' tag manifest

  Scenario: Try to upload invalid tag manifest file over valid tag manifest file
    Given the version with id 'version' for the bag with id 'bag' already has files from fixture 'tag-bag':
      | tagmanifest-md5.txt |
    And the version with id 'version' for the bag with id 'bag' updates its tag manifest 'tagmanifest-md5.txt'
    When I put '/bags/bag/versions/version/contents/tagmanifest-md5.txt' using file 'bag-info.txt' from fixture 'tag-bag'
    Then the response status should be 400
    And the version with id 'version' for the bag with id 'bag' should have content file 'tagmanifest-md5.txt'
    And the version with id 'version' for the bag with id 'bag' should have an 'md5' tag manifest with 5 files

  Scenario: Try to upload tag file with incorrect checksum
    Given the version with id 'version' for the bag with id 'bag' already has files from fixture 'tag-bag':
      | tagmanifest-md5.txt | tagmanifest-sha1.txt |
    And the version with id 'version' for the bag with id 'bag' updates its tag manifest 'tagmanifest-md5.txt'
    And the version with id 'version' for the bag with id 'bag' updates its tag manifest 'tagmanifest-sha1.txt'
    When I put '/bags/bag/versions/version/contents/manifested-tag-file' using file 'extra-file' from fixture 'tag-bag'
    Then the response status should be 400
    And the version with id 'version' for the bag with id 'bag' should not have content file 'manifested-tag-file'

  Scenario: Upload tag file with correct checksum
    Given the version with id 'version' for the bag with id 'bag' already has files from fixture 'tag-bag':
      | tagmanifest-md5.txt | tagmanifest-sha1.txt |
    And the version with id 'version' for the bag with id 'bag' updates its tag manifest 'tagmanifest-md5.txt'
    And the version with id 'version' for the bag with id 'bag' updates its tag manifest 'tagmanifest-sha1.txt'
    When I put '/bags/bag/versions/version/contents/manifested-tag-file' using file 'manifested-tag-file' from fixture 'tag-bag'
    Then the response status should be 201
    And the version with id 'version' for the bag with id 'bag' should have content file 'manifested-tag-file'

  Scenario: Upload tag file not in a manifest (unlike data, this works)
    Given the version with id 'version' for the bag with id 'bag' already has files from fixture 'tag-bag':
      | tagmanifest-md5.txt | tagmanifest-sha1.txt |
    And the version with id 'version' for the bag with id 'bag' updates its tag manifest 'tagmanifest-md5.txt'
    And the version with id 'version' for the bag with id 'bag' updates its tag manifest 'tagmanifest-sha1.txt'
    When I put '/bags/bag/versions/version/contents/extra-file' using file 'extra-file' from fixture 'tag-bag'
    Then the response status should be 201
    And the version with id 'version' for the bag with id 'bag' should have content file 'extra-file'
