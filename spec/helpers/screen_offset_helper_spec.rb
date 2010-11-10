
require 'spec/rspec_helper'

describe ScreenOffsetHelper do
  include ScreenOffsetHelper

  it "should calculate screen offsets" do
    offset_from_screen(1000, 100, 10).should == 910
    offset_from_screen(10, 10, 1000).should == 1000
  end
end
