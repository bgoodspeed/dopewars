
require 'spec/rspec_helper'

class FakeAction
  include BattleSelectorDependencyHelper
end

describe BattleSelectorDependencyHelper do
  include MethodDefinitionMatchers

  before(:each) do
    @helper = FakeAction.new
  end

  it "should be described" do
    @helper.should define(:element_at)
  end
end
