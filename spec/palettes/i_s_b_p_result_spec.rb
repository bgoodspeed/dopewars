
require 'spec/rspec_helper'

describe ISBPResult do
  include DomainMocks
  before(:each) do
    @i_s_b_p_result = ISBPResult.new(nil, nil, mock_wrapper)
  end

  it "should calculate offsets" do
    offsets = @i_s_b_p_result.screen_position_relative_to(0, 0, 0, 0, 30, 20)
    offsets.should == [30,20]
  end
end
