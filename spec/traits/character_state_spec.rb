
require 'spec/rspec_helper'

describe CharacterState do
  include DomainMocks

  before(:each) do
    @attributes = mock_attributes
    @state = CharacterState.new(@attributes, 0, 1, 1, [], 3)
  end

  it "should store current attributes" do
    @state.current_hp.should == 1
    @state.current_mp.should == 1
  end
  it "should define deadness" do
    @state.dead?.should be_false
    @state.current_hp=0
    @state.dead?.should be_true
  end
end
