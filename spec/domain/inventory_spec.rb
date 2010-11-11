
require 'spec/rspec_helper'

describe Inventory do
  before(:each) do
    @item = InventoryItem.new(15, :widget)
    @inventory = Inventory.new(200)
    @inventory_with_stuff = Inventory.new(200)
    @inventory_with_stuff.add_item(2, :foo)
    @inventory_with_stuff.add_item(7, :bar)

  end

  it "has a fixed number of slots" do
    @inventory.free_slots.should == 200
  end

  it "can count" do
    @inventory.inventory_count.should == 0
  end
  it "can get quantities" do
    @inventory.quantity_of(:foo).should == 0
  end
  it "can get size" do
    @inventory.size.should == 0
  end

  it "can add items" do
    @inventory.add_item(3, :foo)
    @inventory.quantity_of(:foo).should == 3
    @inventory.add_item(2, :foo)
    @inventory.quantity_of(:foo).should == 5
  end
  it "can remove items" do
    @inventory.add_item(3, :foo)
    @inventory.remove_item(2, :foo)
    @inventory.quantity_of(:foo).should == 1
  end

  it "can yield inventory info" do
    @inventory.add_item(3, :foo)
    @inventory.add_item(2, :bar)
    @inventory.inventory_count.should == 5
    @inventory.inventory_info.size.should == 2
    @inventory.inventory_item_at(0).should be_an_instance_of(InventoryItem)
  end

  it "can serialize items to info" do
    @item.to_info.should == "widget : 15"
  end
  it "can be consumed" do
    @item.consumed
    @item.to_info.should == "widget : 14"
  end
  it "is jsonified" do
    @item.json_params.should be_an_instance_of Array
  end


  it "should be able to merge/add inventories" do
    @inventory.inventory_count.should == 0
    @inventory.gain_inventory(@inventory_with_stuff)
    @inventory.inventory_count.should == 9
  end
end
