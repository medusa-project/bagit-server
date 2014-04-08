And(/^the content_directory should be empty$/) do
  expect(Dir[File.join(Bag.root_directory, '*')]).to be_empty
end