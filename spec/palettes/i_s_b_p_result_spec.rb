
require 'spec/rspec_helper'

describe ISBPResult do
  include DomainMocks
  before(:each) do

    @result = ISBPResult.new(mock_surface, mock_blocking(true), mock_wrapper)
  end

  it "should calculate offsets" do
    offsets = @result.screen_position_relative_to(0, 0, 0, 0, 30, 20)
    offsets.should == [30,20]
  end

  it "should be blit able" do
    expect_blitted(@result.surface)
    @result.blit(mock_screen, 0,1,2,3)
  end
  
  it "should be blit onto able" do
    expect_blitted(@result.surface)
    @result.blit_onto(mock_screen, :args)
  end
  
  it "should define blocking" do

    @result.is_blocking?.should be_true
    @result.actionable = mock_blocking(false)
    @result.is_blocking?.should be_false
  end

end
