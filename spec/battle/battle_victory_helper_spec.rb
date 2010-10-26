# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'
require 'rubygems'
require 'rubygame'

describe BattleVictoryHelper do
  include MockeryHelp
  include Rubygame
  
  before(:each) do
    @battle_victory_helper = BattleVictoryHelper.new

    @world = mocking(
      :x_offset_for_world => 999, :y_offset_for_world => 888,
      :x_offset_for_interaction => 777, :y_offset_for_interaction => 666
    )
    @surface = mock("fake stub surface")
    @monster_inventory = Inventory.new(234)
    @animated_sprite_helper = mock("animation helper")
    AnimatedSpriteHelper.should_receive(:new).and_return(@animated_sprite_helper)
    @party = Party.new([], Inventory.new(255))
    @uni = mocking(:current_world => @world)
    @player = Player.new(320, 240 ,@uni, @party, "fake", 12, 12, 1111, 2222 )
  end

  it "should delete the monster from the universe" do
    @world.should_receive(:delete_monster)
    @battle_victory_helper.end_battle_from(mocking(:player => @player, :universe => @uni, :monster => mock_monster))
  end

  it "should give spoils from the monster to the player" do
    @battle_victory_helper.give_spoils(@player, mock_monster)
  end

  def mock_monster(exp=1, inventory=Inventory.new(123))
     mocking(:experience => exp, :inventory => inventory)
  end
end

