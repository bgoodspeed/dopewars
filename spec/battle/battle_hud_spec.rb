# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

describe BattleHud do
  include DomainMocks
  
  def mock_screen
    m = mock("screen")
    m
  end
  def mock_text_rendering_helper
    m = mock("text rendering helper")
    m
  end

  before(:each) do
    
    @screen = SurfaceFactory.new.make_surface([100,100])
    @battle_hud = BattleHud.new(@screen, mock_text_rendering_helper, mock_layer)
  end

  it "should map to colors" do
    @battle_hud.map_to_colors(1).should == [:blue, :red,  :red,  :red,  :red,  :red,  :red,  :red,  :red, :red]
    @battle_hud.map_to_colors(5).should == [:blue, :blue, :blue, :blue, :blue, :red,  :red,  :red,  :red, :red]
    @battle_hud.map_to_colors(8).should == [:blue, :blue, :blue, :blue, :blue, :blue, :blue, :blue, :red, :red]
  end

  def battle
    Battle.new(mock_game, MonsterFactory.new.make_monster(mock_player, mock_universe))
  end

  it "should be able to draw" do
    @battle_hud.draw(nil, nil, battle)
  end
end

