
require 'spec/rspec_helper'

describe Universe do
  before(:each) do
    @universe = Universe.new(0, [@world], @layers, @sfx, @game)
  end

  it "should save current world" do
    @universe.current_world.should == @world
  end
end
