FactoryGirl.define do

  #this is needed to run the model callbacks with factory girl
  to_create do |instance|
    unless instance.save
      raise "Save failed for #{instance.class}"
    end
  end

  factory :bag do
    sequence(:bag_id) { |n| "bag-#{n}" }
  end

  factory :version do
    sequence(:version_id) { |n| "version-#{n}" }
    bag
    tag_file_encoding 'UTF-8'
  end

end