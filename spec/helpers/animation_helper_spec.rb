
require 'spec/rspec_helper'

describe AnimationHelper do
  before(:each) do
    @keys = AlwaysDownMonsterKeyHolder.new

    @animation_helper = AnimationHelper.new(@keys, 3)
  end

  def dt
    0.20
  end

  it "should store current frame" do
    @animation_helper.current_frame.should == 0
  end
  
  it "should update frame" do
    how_many = 3
    called = false
    how_many.times { @animation_helper.update_animation(dt) { called = true}}
    @animation_helper.current_frame.should == 1
    called.should be_true
  end
end
