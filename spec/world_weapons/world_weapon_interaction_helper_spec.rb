
require 'spec/rspec_helper'

describe WorldWeaponInteractionHelper do
  include DomainMocks
  before(:each) do
    @world_weapon_interaction_helper = WorldWeaponInteractionHelper.new(mock_game, InteractionPolicy.process_all)
  end

  it "should define interaction options" do
    @world_weapon_interaction_helper.interact_with_current_tile(nil,nil, nil)
    @world_weapon_interaction_helper.interact_with_dialog
    @world_weapon_interaction_helper.interact_with_facing_tile(nil,nil, nil, nil)
    @world_weapon_interaction_helper.interact_with_npc(nil, nil)
  end
end
