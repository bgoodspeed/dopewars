# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

class FakeMenuAction

  include SelectorDependencyHelper
  attr_reader :name,:game,:dependencies
  def initialize(name, game, deps)
    @name =name
    @game = game
    @dependencies = deps
  end
end

describe SelectorDependencyHelper do
  include DomainMocks


  def menu_layer_config

    mlc = MenuLayerConfig.new
    mlc.main_menu_text = TextRenderingConfig.new(@@MENU_TEXT_INSET, 0, @@MENU_TEXT_INSET, @@MENU_LINE_SPACING)
    mlc.section_menu_text = TextRenderingConfig.new(3 * @@MENU_TEXT_INSET + @@MENU_TEXT_WIDTH + @@MENU_LINE_SPACING, 0, @@MENU_TEXT_INSET, @@MENU_LINE_SPACING)
    mlc.in_subsection_cursor = TextRenderingConfig.new(2 * @@MENU_TEXT_INSET + 4*@@MENU_TEXT_WIDTH, 0, 2 * @@MENU_TEXT_INSET, @@MENU_LINE_SPACING)
    mlc.in_option_section_cursor = TextRenderingConfig.new(2 * @@MENU_TEXT_INSET + 4*@@MENU_TEXT_WIDTH, 0, 3 * @@MENU_TEXT_INSET, @@MENU_LINE_SPACING)
    mlc.in_section_cursor = TextRenderingConfig.new(2 * @@MENU_TEXT_INSET + 4*@@MENU_TEXT_WIDTH, 0, @@MENU_TEXT_INSET, @@MENU_LINE_SPACING)
    mlc.main_cursor = TextRenderingConfig.new(2 * @@MENU_TEXT_INSET + @@MENU_TEXT_WIDTH, 0, @@MENU_TEXT_INSET, @@MENU_LINE_SPACING)
    mlc.layer_inset_on_screen = [@@MENU_LAYER_INSET,@@MENU_LAYER_INSET]
    mlc.details_inset_on_layer = [@@MENU_DETAILS_INSET_X, @@MENU_DETAILS_INSET_Y]
    mlc.options_inset_on_layer = [@@MENU_OPTIONS_INSET_X, @@MENU_OPTIONS_INSET_Y]
    mlc
  end


  def mock_selector
    m = mock("mock selector")
    m
  end

  def mock_selections(selected=false)
    m = mock("selections")
    m.stub!(:has_selected?).and_return selected
    m
  end

  before(:each) do
    @game = mock_game
    @selector = mock_selector
    @menu_action = FakeMenuAction.new("foo", @game, [@selector])
  end

  it "should draw to the correct depth -- unselected" do
    @menu_action.draw(menu_layer_config,"1",2,mock_selections)
  end
  it "should draw to the correct depth -- selected" do
    @selector.should_receive(:draw)
    @menu_action.draw(menu_layer_config,"1",2,mock_selections(true))
  end
end

