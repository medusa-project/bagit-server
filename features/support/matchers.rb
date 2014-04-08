require 'rspec/expectations'

RSpec::Matchers.define :contain_a_uuid do
  match do |actual|
    actual.match(/\h{8}-\h{4}-\h{4}-\h{4}-\h{12}/)
  end
end

RSpec::Matchers.define :be_a_uuid do
  match do |actual|
    actual.match(/^\h{8}-\h{4}-\h{4}-\h{4}-\h{12}$/)
  end
end