Feature: Bag population
  In order to fill up my bag
  As a user
  I want to be able to upload files to my bag

  Background:
    Given the bag with id 'test-bag' has a version with id 'test'

  Scenario: Upload bagit.txt
    When I post '/bags/test-bag/versions/test/bagit.txt' using file 'bagit.txt' from fixture 'good-bag'
    Then the response status should be 200
    And the version with id 'test' for the bag with id 'test-bag' should have content file 'bagit.txt'

  Scenario: Upload bag-info.txt
    When I post '/bags/test-bag/versions/test/bag-info.txt' using file 'bag-info.txt' from fixture 'good-bag'
    Then the response status should be 200
    And the version with id 'test' for the bag with id 'test-bag' should have content file 'bag-info.txt'
