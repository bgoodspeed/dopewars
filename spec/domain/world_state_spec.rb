
require 'spec/rspec_helper'

describe WorldState do
  include MethodDefinitionMatchers
  include DomainMocks
  before(:each) do
    @topo = mock_interpreter
    @inter = mock_interpreter
    @world_state = WorldState.new(@topo,@inter, [:monster1, :monster2], nil, @bgm)
    @world_state2 = WorldState.new(mock_interpreter, mock_interpreter, [], nil, @bgm)
  end

  it "should define methods" do
    @world_state.should define(:background_music)
  end

  it "should replace pallettes" do
    expect_replace_pallette(@inter)
    @world_state.replace_pallettes(@world_state2)
  end
  it "should replace bgsurfaces" do
    @world_state2.background_surface = :bar
    @world_state.replace_bgsurface(@world_state2)
    @world_state.background_surface.should == :bar
  end
  it "should replace bgmusic" do
    @world_state2.background_music = :bar
    @world_state.replace_bgmusic(@world_state2)
    @world_state.background_music.should == :bar
  end

  it "should be able to draw by blits and draw calls" do
    @world_state.background_surface = mock_surface
    mon = mock_monster
    @world_state.npcs = [mon]
    expect_blitted(@world_state.background_surface)
    expect_blit_foreground(@world_state.interaction_interpreter)
    expect_nearby_and_drawn(mon)
    @world_state.blit_world(mock_screen, mock_player)
  end
  it "should track npcs" do
    @world_state.add_npc(:monster3)
    @world_state.npcs.should == [:monster1, :monster2, :monster3]
    @world_state.delete_monster(:monster3)
    @world_state.npcs.should == [:monster1, :monster2]
  end

  it "should be json ified" do
    @world_state.json_params.should be_an_instance_of(Array)
  end
  
end
