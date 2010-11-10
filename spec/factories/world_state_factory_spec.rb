
require 'spec/rspec_helper'

describe WorldStateFactory do
  before(:each) do
    @world_state_factory = WorldStateFactory.new
  end

  def bgm
    MusicFactory.new.load_music("bonobo-gypsy.mp3")
  end

  it "should be described" do
    JsonSurface.stub!(:new).and_return nil
    p = Pallette.new(".")
    ip = Pallette.new("#")
    world = WorldStateFactory.build_world_state("world1_bg", "world1_interaction", p, ip, 1280, 960, [], bgm)
    world.should be_an_instance_of WorldState
  end
end
