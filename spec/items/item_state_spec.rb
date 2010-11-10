
require 'spec/rspec_helper'

describe ItemState do
  include DomainMocks
  
  before(:each) do
    @attributes = mock_attributes
    @state = ItemState.new(@attributes, 0, 1, 1, [], 3)
  end

  it "should be have level points" do
    @state.level_points.should == 3
  end
end
