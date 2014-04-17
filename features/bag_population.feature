Feature: Bag population
  In order to fill up my bag
  As a user
  I want to be able to upload files to my bag

  Background:
    Given the bag with id 'test-bag' has a version with id 'test'

  Scenario: Upload bagit.txt
    When I put '/bags/test-bag/versions/test/contents/bagit.txt' using file 'bagit.txt' from fixture 'good-bag'
    Then the response status should be 201
    And the version with id 'test' for the bag with id 'test-bag' should have content file 'bagit.txt'
    And the version with id 'test' for the bag with id 'test-bag' should have tag file encoding 'UTF-8'

  Scenario: Upload invalid bagit.txt
    When I put '/bags/test-bag/versions/test/contents/bagit.txt' using file 'manifest-md5.txt' from fixture 'good-bag'
    Then the response status should be 400
    And the version with id 'test' for the bag with id 'test-bag' should not have content file 'bagit.txt'

  Scenario: Upload bag-info.txt
    When I put '/bags/test-bag/versions/test/contents/bag-info.txt' using file 'bag-info.txt' from fixture 'good-bag'
    Then the response status should be 201
    And the version with id 'test' for the bag with id 'test-bag' should have content file 'bag-info.txt'

  Scenario: Upload invalid bag-info.txt
    When I put '/bags/test-bag/versions/test/contents/bag-info.txt' using file 'manifest-md5.txt' from fixture 'good-bag'
    Then the response status should be 400
    And the version with id 'test' for the bag with id 'test-bag' should not have content file 'bag-info.txt'

  Scenario: Upload top level file without bag files being present
    When I put '/bags/test-bag/versions/test/contents/extra-file' using file 'extra-file' from fixture 'good-bag'
    Then the response status should be 400
    And the version with id 'test' for the bag with id 'test-bag' should not have content file 'extra-file'

  Scenario: Upload top level file with bag files being present
    Given the version with id 'test' for the bag with id 'test-bag' already has files from fixture 'good-bag':
      | bagit.txt | bag-info.txt |
    When I put '/bags/test-bag/versions/test/contents/extra-file' using file 'extra-file' from fixture 'good-bag'
    Then the response status should be 201
    And the version with id 'test' for the bag with id 'test-bag' should have content file 'extra-file'

  Scenario: Upload manifest file
    Given the version with id 'test' for the bag with id 'test-bag' already has files from fixture 'good-bag':
      | bagit.txt | bag-info.txt |
    When I put '/bags/test-bag/versions/test/contents/manifest-md5.txt' using file 'manifest-md5.txt' from fixture 'good-bag'
    Then the response status should be 201
    And the version with id 'test' for the bag with id 'test-bag' should have content file 'manifest-md5.txt'
    And the version with id 'test' for the bag with id 'test-bag' should have an 'md5' manifest with 2 files

  Scenario: Initially upload invalid manifest file
    Given the version with id 'test' for the bag with id 'test-bag' already has files from fixture 'good-bag':
      | bagit.txt | bag-info.txt |
    When I put '/bags/test-bag/versions/test/contents/manifest-md5.txt' using file 'bag-info.txt' from fixture 'good-bag'
    Then the response status should be 400
    And the version with id 'test' for the bag with id 'test-bag' should not have content file 'manifest-md5.txt'
    And the version with id 'test' for the bag with id 'test-bag' should not have an 'md5' manifest

  Scenario: Try to upload invalid manifest file over valid manifest file
    Given the version with id 'test' for the bag with id 'test-bag' already has files from fixture 'good-bag':
      | bagit.txt | bag-info.txt | manifest-md5.txt |
    And the version with id 'test' for the bag with id 'test-bag' updates its manifest 'manifest-md5.txt'
    When I put '/bags/test-bag/versions/test/contents/manifest-md5.txt' using file 'bag-info.txt' from fixture 'good-bag'
    Then the response status should be 400
    And the version with id 'test' for the bag with id 'test-bag' should have content file 'manifest-md5.txt'
    And the version with id 'test' for the bag with id 'test-bag' should have an 'md5' manifest with 2 files

  Scenario: Try to upload content file without bag files and manifest file
    When I put '/bags/test-bag/versions/test/contents/data/grass.jpg' using file 'data/grass.jpg' from fixture 'good-bag'
    Then the response status should be 400
    And the version with id 'test' for the bag with id 'test-bag' should not have content file 'data/grass.jpg'

  Scenario: Try to upload content file with bag files but with no manifest file
    Given the version with id 'test' for the bag with id 'test-bag' already has files from fixture 'good-bag':
      | bagit.txt | bag-info.txt |
    When I put '/bags/test-bag/versions/test/contents/data/grass.jpg' using file 'data/grass.jpg' from fixture 'good-bag'
    Then the response status should be 400
    And the version with id 'test' for the bag with id 'test-bag' should not have content file 'data/grass.jpg'

  Scenario: Upload content file with bag files and manifest file
    Given the version with id 'test' for the bag with id 'test-bag' already has files from fixture 'good-bag':
      | bagit.txt | bag-info.txt | manifest-md5.txt |
    And the version with id 'test' for the bag with id 'test-bag' updates its manifest 'manifest-md5.txt'
    When I put '/bags/test-bag/versions/test/contents/data/grass.jpg' using file 'data/grass.jpg' from fixture 'good-bag'
    Then the response status should be 201
    And the version with id 'test' for the bag with id 'test-bag' should have content file 'data/grass.jpg'

  Scenario: Try to upload content file with incorrect checksum
    Given the version with id 'test' for the bag with id 'test-bag' already has files from fixture 'good-bag':
      | bagit.txt | bag-info.txt | manifest-md5.txt |
    And the version with id 'test' for the bag with id 'test-bag' updates its manifest 'manifest-md5.txt'
    When I put '/bags/test-bag/versions/test/contents/data/grass.jpg' using file 'bagit.txt' from fixture 'good-bag'
    Then the response status should be 400
    And the version with id 'test' for the bag with id 'test-bag' should not have content file 'data/grass.jpg'

  Scenario: Try to upload content file not in a manifest
    Given the version with id 'test' for the bag with id 'test-bag' already has files from fixture 'good-bag':
      | bagit.txt | bag-info.txt | manifest-md5.txt |
    And the version with id 'test' for the bag with id 'test-bag' updates its manifest 'manifest-md5.txt'
    When I put '/bags/test-bag/versions/test/contents/data/weeds.jpg' using file 'data/grass.jpg' from fixture 'good-bag'
    Then the response status should be 400
    And the version with id 'test' for the bag with id 'test-bag' should not have content file 'data/weeds.jpg'

  Scenario: Allow upload to version in certain states
    Then I can upload to the version with id 'test' for the bag with id 'test-bag' when in validation states:
      | unvalidated | invalid |

  Scenario: Disallow upload to version in certain states
    Then I cannot upload to the version with id 'test' for the bag with id 'test-bag' when in validation states:
      | valid | validating | uploading | committed |
