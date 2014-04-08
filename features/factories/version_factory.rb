FactoryGirl.define do
  factory :version do
    sequence(:version_id) {|n| "version-#{n}"}
    bag
  end
end