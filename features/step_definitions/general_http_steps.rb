When(/^I post '(.*)' with JSON fields:$/) do |url, table|
  post url, table.hashes.first.to_json
end

When(/^I delete '(.*)'$/) do |url|
  delete url
end

Then(/^the response status should be (\d+)$/) do |code|
  expect(last_response.status.to_s).to eq(code)
end

And(/^the response header '(.*)' should be '(.*)'$/) do |name, value|
  expect(last_response.headers[name]).to eq(value)
end

And(/^the response header '(.*)' should match '(.*)'$/) do |name, value|
  expect(last_response.headers[name]).to match(value)
end

And(/^the response header '(.*)' should match some uuid$/) do |name|
  expect(last_response.headers[name]).to contain_a_uuid
end

When(/^I post '(.*)' using file '(.*)' from fixture '(.*)'$/) do |url, file, fixture|
  post url, fixture_file_content(fixture, file)
end

def fixture_file_content(fixture, file)
  File.read(File.join(fixture_root, fixture, file))
end