
require 'spec/rspec_helper'

describe EquipmentHolder do
  before(:each) do
    @equipment_holder = EquipmentHolder.new
  end

  it "should have slots" do
    @equipment_holder.slots.should == [:head, :body, :feet, :left_hand, :right_hand]
  end

  it "should manage equipment" do
    @equipment_holder.equip_on(:feet, :shoes_of_glory)
    @equipment_holder.equipped_on(:feet).should == :shoes_of_glory
    @equipment_holder.equip_in_slot_index(2, :other_shoes)
    @equipment_holder.equipped_on(:feet).should == :other_shoes

  end

  it "should get equipment info" do
    @equipment_holder.equipment_info.each {|info|
      info.should be_an_instance_of EquipmentInfo
    }
  end
end
