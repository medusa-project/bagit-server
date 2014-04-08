require 'fileutils'

#before each test make sure that the contents directory is empty. Each test will set this up for itself.
Before do
  Dir[File.join(Bag.root_directory, '*')].each do |dir|
    FileUtils.rm_rf(dir)
  end
end