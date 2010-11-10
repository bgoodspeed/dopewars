
require 'spec/rspec_helper'

describe ClockFacade do
  before(:each) do
    @clock_facade = ClockFacade.new
  end

  it "should behave as a clock" do
    @clock_facade.ticks.should == 0
    @clock_facade.ticks.should == 0
  end
end
