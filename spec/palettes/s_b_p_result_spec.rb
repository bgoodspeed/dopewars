
require 'spec/rspec_helper'

describe SBPResult do
  include DomainMocks
  include DelegationMatchers

  before(:each) do
    @result = SBPResult.new(mock("surface"),mock("actionable"),mock_wrapper)
  end

  it "should be able to calculate screen positions" do
    offsets = @result.screen_position_relative_to(0, 0, 0, 0, 200, 100)
    offsets.should == [200,100]
  end

  it "should blit to the surface to draw" do
    expect_blitted(@result.surface)
    @result.blit(:screen, :offsets)
  end

  it "should determine blocking by the actionable" do
    @result.should delegate_to({:is_blocking? => []}, {:actionable => :is_blocking?})
  end

end
