FactoryGirl.define do
  factory :bag do
    sequence(:bag_id) {|n| "bag-#{n}"}
  end
end