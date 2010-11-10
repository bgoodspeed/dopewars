
require 'spec/rspec_helper'

describe EquipmentInfo do
  before(:each) do
    @info = EquipmentInfo.new(:feet, nil)
  end

  it "should be serializable to string" do
    @info.to_s.should == "feet: empty"
  end
end
