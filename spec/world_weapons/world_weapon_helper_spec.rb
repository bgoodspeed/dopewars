
require 'spec/rspec_helper'

describe WorldWeaponHelper do
  include DomainMocks

  def weapon
    @game.player.world_weapon
  end

  def expect_weapon_fired_once
    weapon.should_receive(:fired_from).with(1122, 3344, :down)
  end
  
  def expect_weapon_displayed_once
    weapon.should_receive(:displayed)
  end
  def expect_weapon_unconsumed
    weapon.should_receive(:consumed?).and_return false
  end
  
  before(:each) do
    @game = mock_game
    @interaction_helper = mock_interaction_helper
    @world_weapon_helper = WorldWeaponHelper.new(@game, @interaction_helper)
  end


  it "should know when its active -- inactive" do
    @world_weapon_helper.using_weapon?.should be_false
  end
  
  it "should know when its active" do
    expect_weapon_fired_once
    @world_weapon_helper.use_weapon
    @world_weapon_helper.using_weapon?.should be_true
  end

  it "should know only use weapon if not in use" do
    expect_weapon_fired_once
    @world_weapon_helper.use_weapon
    @world_weapon_helper.use_weapon
    
  end


  it "should update if active -- active case" do
    expect_weapon_fired_once
    @world_weapon_helper.use_weapon
    expect_weapon_displayed_once
    expect_weapon_unconsumed
    @interaction_helper.should_receive(:interact_with_facing).with(@game, 1122, 3344)
    @world_weapon_helper.update_weapon_if_active
  end

  it "should update if active -- inactive case" do
    @world_weapon_helper.update_weapon_if_active
  end
end
