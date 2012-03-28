RSpec::Matchers.define :be_in do |expected|

  match do |actual|
    expected.include?(actual)
  end

end
