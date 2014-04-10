When(/^I post '(.*)' with JSON fields:$/) do |url, table|
  post url, nil, {:input => table.hashes.first.to_json, "Content-Type" => 'application/octet-stream'}
end

When(/^I delete '(.*)'$/) do |url|
  delete url
end

When(/^I get '(.*)'$/) do |url|
  get url
end

When(/^I put '(.*)' using file '(.*)' from fixture '(.*)'$/) do |url, file, fixture|
  put url, nil, {:input => fixture_file_content(fixture, file), "Content-Type" => 'application/octet-stream'}
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

And(/^the response body should equal the file '(.*)' from the fixture '(.*)'$/) do |path, fixture|
  expect(last_response.body).to eq(fixture_file_content(fixture, path))
end

def fixture_file_content(fixture, file)
  File.read(File.join(fixture_root, fixture, file))
end