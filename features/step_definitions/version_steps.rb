require 'fileutils'
And(/^the bag with id '(.*)' should have a version with id '(.*)'$/) do |bag_id, version_id|
  expect(Bag.first(bag_id: bag_id).versions.first(version_id: version_id)).to be_a(Version)
end

And(/^there should be (\d+) versions?$/) do |count|
  expect(Version.count.to_s).to eq(count)
end

And(/^the version with id '(.*)' for the bag with id '(.*)' should have content file '(.*)'$/) do |version_id, bag_id, path|
  version = Bag.first(bag_id: bag_id).versions.first(version_id: version_id)
  expect(File.exists?(File.join(version.path, path))).to be_true
end

And(/^the version with id '(.*)' for the bag with id '(.*)' should not have content file '(.*)'$/) do |version_id, bag_id, path|
  version = Bag.first(bag_id: bag_id).versions.first(version_id: version_id)
  expect(File.exists?(File.join(version.path, path))).to be_false
end

Given(/^the version with id '(.*)' for the bag with id '(.*)' already has files from fixture '(.*)':$/) do |version_id, bag_id, fixture, table|
  version = Bag.first(bag_id: bag_id).versions.first(version_id: version_id)
  table.headers.each do |file|
    FileUtils.copy(fixture_path(fixture, file), File.join(version.path, file))
  end
end

And(/^the version with id '(.*)' for the bag with id '(.*)' has contents the fixture '(.*)'$/) do |version_id, bag_id, fixture|
  version = Bag.first(bag_id: bag_id).versions.first(version_id: version_id)
  copy_fixture(fixture, version.path)
end

And(/^the version with id '(.*)' for the bag with id '(.*)' should have an? '(.*)' manifest with (\d+) files$/) do |version_id, bag_id, checksum_algorithm, file_count|
  version = Bag.first(bag_id: bag_id).versions.first(version_id: version_id)
  manifest = version.manifests.first(algorithm: checksum_algorithm)
  expect(manifest).to be_a(Manifest)
  expect(manifest.manifest_files.count.to_s).to eq(file_count)
end

And(/^the version with id '(.*)' for the bag with id '(.*)' should not have an? '(.*)' manifest$/) do |version_id, bag_id, checksum_algorithm|
  version = Bag.first(bag_id: bag_id).versions.first(version_id: version_id)
  manifest = version.manifests.first(algorithm: checksum_algorithm)
  expect(manifest).to be_nil
end

And(/^the version with id '(.*)' for the bag with id '(.*)' updates its manifest '(.*)'$/) do |version_id, bag_id, manifest_file|
  version = Bag.first(bag_id: bag_id).versions.first(version_id: version_id)
  version.update_manifest_if_manifest(manifest_file)
end

Then(/^I can upload to the version with id '(.*)' for the bag with id '(.*)' when in validation states:$/) do |version_id, bag_id, table|
  version = Bag.first(bag_id: bag_id).versions.first(version_id: version_id)
  validation = version.validation
  table.headers.each do |validation_status|
    validation.status = validation_status.to_sym
    validation.save!
    step "I put '/bags/#{bag_id}/versions/#{version_id}/contents/bagit.txt' using file 'bagit.txt' from fixture 'good-bag'"
    step "the response status should be 201"
  end
end

Then(/^I cannot upload to the version with id '(.*)' for the bag with id '(.*)' when in validation states:$/) do |version_id, bag_id, table|
  version = Bag.first(bag_id: bag_id).versions.first(version_id: version_id)
  validation = version.validation
  table.headers.each do |validation_status|
    validation.status = validation_status.to_sym
    validation.save!
    step "I put '/bags/#{bag_id}/versions/#{version_id}/contents/bagit.txt' using file 'bagit.txt' from fixture 'good-bag'"
    step "the response status should be 405"
  end
end

Then(/^I can delete from a version when in validation states:$/) do |table|
  table.headers.each do |validation_status|
    step "the bag with id 'test' has a version with id '#{validation_status}'"
    step "the version with id '#{validation_status}' for the bag with id 'test' has contents the fixture 'good-bag'"
    step "the version with id '#{validation_status}' for the bag with id 'test' updates its manifest 'manifest-md5.txt'"
    step "I delete '/bags/test/versions/#{validation_status}/contents/bagit.txt'"
    step 'the response status should be 204'
  end
end

Then(/^I cannot delete from a version when in validation states:$/) do |table|
  table.headers.each do |validation_status|
    step "the bag with id 'test' has a version with id '#{validation_status}'"
    step "the version with id '#{validation_status}' for the bag with id 'test' has contents the fixture 'good-bag'"
    step "the version with id '#{validation_status}' for the bag with id 'test' updates its manifest 'manifest-md5.txt'"
    validation = Bag.first(bag_id: 'test').versions.first(version_id: validation_status).validation
    validation.status = validation_status
    validation.save!
    step "I delete '/bags/test/versions/#{validation_status}/contents/bagit.txt'"
    step 'the response status should be 405'
  end
end


def copy_fixture(fixture, path)
  Dir[fixture_path(fixture, '*')].each do |entry|
    next if entry == '.' or entry == '..'
    FileUtils.cp_r(entry, path)
  end
end