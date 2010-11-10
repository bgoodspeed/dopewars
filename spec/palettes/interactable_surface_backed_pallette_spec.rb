
require 'spec/rspec_helper'

describe InteractableSurfaceBackedPallette do
  before(:each) do
    @interactable_surface_backed_pallette = InteractableSurfaceBackedPallette.new("treasure-boxes-160.png", 160, 160)
  end

  it "should know the tile size" do
    @interactable_surface_backed_pallette.tile_x.should == 160
    @interactable_surface_backed_pallette.tile_y.should == 160
  end
end
