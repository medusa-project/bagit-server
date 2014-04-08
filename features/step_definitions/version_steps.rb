And(/^the bag with id '(.*)' should have a version with id '(.*)'$/) do |bag_id, version_id|
  expect(Bag.first(bag_id: bag_id).versions.first(version_id: version_id)).to be_a(Version)
end

And(/^there should be (\d+) versions?$/) do |count|
  expect(Version.count.to_s).to eq(count)
end