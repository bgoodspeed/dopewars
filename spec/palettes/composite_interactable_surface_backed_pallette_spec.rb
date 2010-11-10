
require 'spec/rspec_helper'

describe CompositeInteractableSurfaceBackedPallette do
  before(:each) do
    @pal = CompositeInteractableSurfaceBackedPallette.new([["treasure-boxes.png", 32,32], ["weapons-32x32.png", 32,32]])
    @pal['O'] = CISBPEntry.new(["treasure-boxes.png",4,7],OpenTreasure.new("O"))
  end

  it "should find the appropriate subpal" do
    @pal['O'].surface.w.should == 32
    @pal['O'].surface.h.should == 32
  end
  
  it "should return nil for missing" do
    @pal['Z'].should be_nil
  end
end
