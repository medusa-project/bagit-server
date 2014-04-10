Feature: Access to bag contents
  In order to get the information in a bag
  As a user
  I want to be able to download files from the bag

  Background:
    Given the bag with id 'test-bag' has a version with id 'test'
    And the version with id 'test' for the bag with id 'test-bag' has contents the fixture 'good-bag'
    And the version with id 'test' for the bag with id 'test-bag' updates its manifest 'manifest-md5.txt'
