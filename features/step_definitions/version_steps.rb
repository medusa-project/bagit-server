require 'fileutils'
And(/^the bag with id '(.*)' should have a version with id '(.*)'$/) do |bag_id, version_id|
  expect(Bag.first(bag_id: bag_id).versions.first(version_id: version_id)).to be_a(Version)
end

And(/^there should be (\d+) versions?$/) do |count|
  expect(Version.count.to_s).to eq(count)
end

And(/^the version with id '(.*)' for the bag with id '(.*)' should have tag file encoding '(.*)'$/) do |version_id, bag_id, encoding|
  version = Bag.first(bag_id: bag_id).versions.first(version_id: version_id)
  expect(version.tag_file_encoding).to eq(encoding)
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

And(/^the version with id '(.*)' for the bag with id '(.*)' should have an? '(.*)' tag manifest with (\d+) files$/) do |version_id, bag_id, checksum_algorithm, file_count|
  version = Bag.first(bag_id: bag_id).versions.first(version_id: version_id)
  tag_manifest = version.tag_manifests.first(algorithm: checksum_algorithm)
  expect(tag_manifest).to be_a(TagManifest)
  expect(tag_manifest.tag_manifest_files.count.to_s).to eq(file_count)
end

And(/^the version with id '(.*)' for the bag with id '(.*)' should not have an? '(.*)' manifest$/) do |version_id, bag_id, checksum_algorithm|
  version = Bag.first(bag_id: bag_id).versions.first(version_id: version_id)
  manifest = version.manifests.first(algorithm: checksum_algorithm)
  expect(manifest).to be_nil
end

And(/^the version with id '(.*)' for the bag with id '(.*)' should not have an? '(.*)' tag manifest$/) do |version_id, bag_id, checksum_algorithm|
  version = Bag.first(bag_id: bag_id).versions.first(version_id: version_id)
  tag_manifest = version.tag_manifests.first(algorithm: checksum_algorithm)
  expect(tag_manifest).to be_nil
end

And(/^the version with id '(.*)' for the bag with id '(.*)' updates its manifest '(.*)'$/) do |version_id, bag_id, manifest_file|
  version = Bag.first(bag_id: bag_id).versions.first(version_id: version_id)
  version.update_if_manifest(manifest_file)
end

And(/^the version with id '(.*)' for the bag with id '(.*)' updates its tag manifest '(.*)'$/) do |version_id, bag_id, tag_manifest_file|
  version = Bag.first(bag_id: bag_id).versions.first(version_id: version_id)
  version.update_if_tag_manifest(tag_manifest_file)
end

Given(/^the version with id '(.*)' for the bag with id '(.*)' has validation status '(.*)'$/) do |version_id, bag_id, validation_status|
  version = Bag.first(bag_id: bag_id).versions.first(version_id: version_id)
  version.validation_status = validation_status
end

And(/^the version with id '(.*)' for the bag with id '(.*)' should have validation status '(.*)'$/) do |version_id, bag_id, validation_status|
  version = Bag.first(bag_id: bag_id).versions.first(version_id: version_id)
  expect(version.validation_status.to_s).to eq(validation_status)
end

Then(/^I can upload to the version with id '(.*)' for the bag with id '(.*)' when in validation states:$/) do |version_id, bag_id, table|
  version = Bag.first(bag_id: bag_id).versions.first(version_id: version_id)
  table.headers.each do |validation_status|
    version.validation_status = validation_status
    step "I put '/bags/#{bag_id}/versions/#{version_id}/contents/bagit.txt' using file 'bagit.txt' from fixture 'good-bag'"
    step 'the response status should be 201'
  end
end

Then(/^I cannot upload to the version with id '(.*)' for the bag with id '(.*)' when in validation states:$/) do |version_id, bag_id, table|
  version = Bag.first(bag_id: bag_id).versions.first(version_id: version_id)
  table.headers.each do |validation_status|
    version.validation_status = validation_status
    step "I put '/bags/#{bag_id}/versions/#{version_id}/contents/bagit.txt' using file 'bagit.txt' from fixture 'good-bag'"
    step 'the response status should be 405'
  end
end

Then(/^I cannot fetch to the version with id '(.*)' for the bag with id '(.*)' when in validation states:$/) do |version_id, bag_id, table|
  version = Bag.first(bag_id: bag_id).versions.first(version_id: version_id)
  table.headers.each do |validation_status|
    version.validation_status = validation_status
    step "I post '/bags/#{bag_id}/versions/#{version_id}/fetch'"
    step 'the response status should be 405'
  end
end

Then(/^I cannot validate the version with id '(.*)' for the bag with id '(.*)' when in validation states:$/) do |version_id, bag_id, table|
  version = Bag.first(bag_id: bag_id).versions.first(version_id: version_id)
  table.headers.each do |validation_status|
    version.validation_status = validation_status
    step "I post '/bags/#{bag_id}/versions/#{version_id}/validate'"
    step 'the response status should be 405'
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
    Bag.first(bag_id: 'test').versions.first(version_id: validation_status).validation_status = validation_status
    step "I delete '/bags/test/versions/#{validation_status}/contents/bagit.txt'"
    step 'the response status should be 405'
  end
end

Then(/^I cannot commit a version with validation states:$/) do |table|
  table.headers.each do |validation_status|
    step "the bag with id 'test' has a version with id '#{validation_status}'"
    step "the version with id '#{validation_status}' for the bag with id 'test' has contents the fixture 'good-bag'"
    step "the version with id '#{validation_status}' for the bag with id 'test' updates its manifest 'manifest-md5.txt'"
    Bag.first(bag_id: 'test').versions.first(version_id: validation_status).validation_status = validation_status
    step "I post '/bags/test/versions/#{validation_status}/commit'"
    step 'the response status should be 405'
  end
end

When(/^I fetch the version with id '(.*)' for the bag with id '(.*)'$/) do |version_id, bag_id|
  version = Bag.first(bag_id: bag_id).versions.first(version_id: version_id)
  version.fetch
end


def copy_fixture(fixture, path)
  Dir[fixture_path(fixture, '*')].each do |entry|
    next if entry == '.' or entry == '..'
    FileUtils.cp_r(entry, path)
  end
end