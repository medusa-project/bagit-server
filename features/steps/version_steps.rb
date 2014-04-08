And(/^the bag with id '(.*)' should have a version with id '(.*)'$/) do |bag_id, version_id|
  b = Bag.all
  v = Version.all
  expect(Bag.first(bag_id: bag_id).versions.first(version_id: version_id)).to be_a(Version)
end