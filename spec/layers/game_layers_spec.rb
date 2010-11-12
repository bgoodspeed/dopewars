
require 'spec/rspec_helper'

describe GameLayers do
  include DomainMocks
  include MethodDefinitionMatchers
  include DelegationMatchers
  def mock_layer
    m = mock("layer")
    m
  end

  before(:each) do
    @dialog = mock_layer
    @menu = mock_layer
    @battle = mock_layer
    @notifications = mock_layer
    @game_layers = GameLayers.new(@dialog, @menu, @battle, @notifications)
  end

  it "should define layer accessors" do
    @game_layers.should define(:menu_layer)
  end

  def stub_active_layers(dl, bl, ml, nl)
    stub_active(@game_layers.dialog_layer, dl)
    stub_active(@game_layers.battle_layer, bl)
    stub_active(@game_layers.menu_layer, ml)
    stub_active(@game_layers.notifications_layer, nl)

  end

  it "should draw dialog if active" do
    stub_active_layers(true, false, false, false)
    expect_draw(@game_layers.dialog_layer)
    @game_layers.draw_game_layers_if_active
  end
  it "should draw menu if active" do
    stub_active_layers(false, false, true, false)
    expect_draw(@game_layers.menu_layer)
    @game_layers.draw_game_layers_if_active
  end
  it "should draw battle if active" do
    stub_active_layers(false, true, false, false)
    expect_draw(@game_layers.battle_layer)
    @game_layers.draw_game_layers_if_active
  end
  it "should draw notifications if active" do
    stub_active_layers(false, false, false, true)
    expect_draw(@game_layers.notifications_layer)
    @game_layers.draw_game_layers_if_active
  end

  it "should delegate reset menu positions" do
    @game_layers.should delegate_to({:reset_menu_positions => []}, {:menu_layer => :reset_indices})
  end

  
end
