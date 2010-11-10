
require 'spec/rspec_helper'

describe EquipmentHolder do
  before(:each) do
    @equipment_holder = EquipmentHolder.new
  end

  it "should have slots" do
    @equipment_holder.slots.should == [:head, :body, :feet, :left_hand, :right_hand]
  end
end
