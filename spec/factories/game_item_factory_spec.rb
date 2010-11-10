
require 'spec/rspec_helper'

describe GameItemFactory do
  before(:each) do
    @game_item_factory = GameItemFactory.new
  end

  it "should create items" do
    GameItemFactory.antidote.should be_an_instance_of GameItem
    GameItemFactory.potion.should be_an_instance_of GameItem
    GameItemFactory.sword.should be_an_instance_of EquippableGameItem
  end
end
