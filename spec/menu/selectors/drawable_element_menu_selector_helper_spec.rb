
require 'spec/rspec_helper'

class FakeDrawable
  include DrawableElementMenuSelectorHelper
end

describe DrawableElementMenuSelectorHelper do
  include MethodDefinitionMatchers
  
  before(:each) do
    @helper = FakeDrawable.new
  end

  it "should give draw methods" do
    @helper.should define(:draw)
  end
end
