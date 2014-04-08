When(/^I post to '(.*)' with JSON fields:$/) do |url, table|
  post url, table.hashes.first.to_json
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
