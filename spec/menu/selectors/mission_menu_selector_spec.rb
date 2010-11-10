# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

describe MissionMenuSelector do
  include DomainMocks
  include MenuSelectorMatchers
  before(:each) do
    @game = mock_game
    @menu_selector = MissionMenuSelector.new(@game)
  end

  it "is a menu selector" do
    @menu_selector.should behave_as_a_menu_selector
  end

  it "should ask the game for missions" do
    @game.should_receive(:player_missions)
    @menu_selector.elements(nil)
  end
end

