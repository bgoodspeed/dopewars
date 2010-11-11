
require 'spec/rspec_helper'

describe MenuAction do
  before(:each) do
    @menu_action = MenuAction.new(@game, "foo", [:dep1])
  end

  it "should have a name" do
    @menu_action.name.should == "foo"
  end
end
