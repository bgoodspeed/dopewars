
require 'spec/rspec_helper'

describe JsonLoadableSurface do
  before(:each) do
    @surface = JsonLoadableSurface.new("scaled-background-20x20.png", false)
  end

  #TODO review saving/loading these classes might not need to exist
  it "should pass along blocking" do
    @surface.is_blocking?.should be_false
  end
end
