
require 'spec/rspec_helper'

describe KeyPressedFacade do
  before(:each) do
    @key_pressed_facade = KeyPressedFacade.new(:space)
  end

  it "should store the key" do
    @key_pressed_facade.key.should == :space
  end
end
