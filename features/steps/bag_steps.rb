And(/^there should be a bag with id '(.*)'$/) do |bag_id|
  expect(Bag.first(bag_id: bag_id)).to be_a(Bag)
end

And(/^the content directory should exist for the bag '(.*)' and version '(.*)'$/) do |bag_id, version_id|
  version = Bag.first(bag_id: bag_id).versions.first(version_id: version_id)
  expect(File.directory?(version.path)).to be_true
end