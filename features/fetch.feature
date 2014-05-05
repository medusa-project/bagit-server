Feature: Bagit fetch
  In order to simplify the transfer of bags
  As a user
  I want to be able to use the bagit fetch.txt feature

  Background:
    Given the bag with id 'fetch' has a version with id 'version'
    And the version with id 'version' for the bag with id 'fetch' already has files from fixture 'fetch-bag':
      | bagit.txt | bag-info.txt | manifest-md5.txt |

  Scenario: Upload a correct fetch.txt file
    When I put '/bags/fetch/versions/version/contents/fetch.txt' using file 'fetch.txt' from fixture 'fetch-bag'
    Then the response status should be 201
    And the version with id 'version' for the bag with id 'fetch' should have content file 'fetch.txt'

  Scenario: Upload an incorrect fetch.txt file
    When I put '/bags/fetch/versions/version/contents/fetch.txt' using file 'manifest-md5.txt' from fixture 'fetch-bag'
    Then the response status should be 400
    And the version with id 'version' for the bag with id 'fetch' should not have content file 'fetch.txt'

  Scenario: Execute fetch for a version
    And the version with id 'version' for the bag with id 'fetch' already has files from fixture 'fetch-bag':
      | fetch.txt |
    When I post '/bags/fetch/versions/version/fetch'
    Then the response status should be 200
    Then the version with id 'version' for the bag with id 'fetch' should have content file 'data/grass.jpg'
    And the version with id 'version' for the bag with id 'fetch' should have content file 'data/return.xml'

  Scenario: Fetch fails if the version is not in an appropriate state
    Then I cannot fetch to the version with id 'version' for the bag with id 'fetch' when in validation states:
      | valid | validating | uploading | committed |
