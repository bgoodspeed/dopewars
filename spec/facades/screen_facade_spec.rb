
require 'spec/rspec_helper'

describe ScreenFacade do
  before(:each) do
    @screen_facade = ScreenFacade.new([123,456])
  end

  it "should be described" do
    @screen_facade.w.should == 123
    @screen_facade.h.should == 456
  end
end
