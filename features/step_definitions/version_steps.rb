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