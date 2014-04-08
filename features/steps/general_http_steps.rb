When(/^I post to '(.*)' with JSON fields:$/) do |url, table|
  post url, table.hashes.first.to_json
end

Then(/^the response status should be (\d+)$/) do |code|
  expect(last_response.status.to_s).to eq(code)
end

And(/^the response header '(.*)' should be '(.*)'$/) do |name, value|
  expect(last_response.headers['Location']).to eq(value)
end