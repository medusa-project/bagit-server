Feature: Access to bag contents
  In order to get the information in a bag
  As a user
  I want to be able to download files from the bag

  Background:
    Given the bag with id 'test-bag' has a version with id 'test'
    And the version with id 'test' for the bag with id 'test-bag' has contents the fixture 'good-bag'
    And the version with id 'test' for the bag with id 'test-bag' updates its manifest 'manifest-md5.txt'

  Scenario: Get a top level file
    When I get '/bags/test-bag/versions/test/contents/bagit.txt'
    Then the response status should be 200
    And the response header 'Content-Type' should be 'application/octet-stream'
    And the response body should equal the file 'bagit.txt' from the fixture 'good-bag'

  Scenario: Get a data file
    When I get '/bags/test-bag/versions/test/contents/data/grass.jpg'
    Then the response status should be 200
    And the response header 'Content-Type' should be 'application/octet-stream'
    And the response body should equal the file 'data/grass.jpg' from the fixture 'good-bag'

  Scenario: Try to get a file that is not present
    When I get '/bags/test-bag/versions/test/contents/data/weeds.jpg'
    Then the response status should be 404
