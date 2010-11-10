
require 'spec/rspec_helper'

describe SBPResult do
  include DomainMocks

  before(:each) do
    @s_b_p_result = SBPResult.new(nil,nil,mock_wrapper)
  end

  it "should be described" do
    offsets = @s_b_p_result.screen_position_relative_to(0, 0, 0, 0, 200, 100)
    offsets.should == [200,100]
  end
end
