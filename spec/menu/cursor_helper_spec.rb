# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

describe CursorHelper do
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

  def named_mock(name)
    m = mock("named mock: #{name}")
    m.stub!(:name).and_return name
    m
  end

  def hero(name)
    h = Hero.new(name,nil, 1, 1, CharacterAttribution.new(CharacterState.new(CharacterAttributes.new(0,1,2,3,4,5,6,7)), nil))
    h
  end

  def item(name)
    i = InventoryItem.new(1, GameItem.new(name, ItemState.new(ItemAttributes.none)))
    i
  end

  def mock_game
    g = mock("game")
    g.stub!(:party_members).and_return([hero("person a"), hero("person b")])
    g.stub!(:inventory_info).and_return([item("item 1")])
    g
  end

  def mock_action
    g = mock("action")
    g
  end
  before(:each) do
    @cursor_helper = CursorHelper.new([20,20])
    @game = mock_game()
    @stat_action = StatLineInfoMenuAction.new(@game)
    @mock_action = mock_action
    @item_action = UseItemMenuAction.new(@game, @mock_action)

    @menu = TaskMenu.new(@game, [
        @stat_action,
        @item_action,
      ])
  end

  it "should track actions" do
    @cursor_helper.currently_selected.size.should == 0
    @cursor_helper.activate(@menu)
    @cursor_helper.currently_selected.size.should == 1
    @cursor_helper.currently_selected.search_selected_for(StatLineInfoMenuAction).should_not be_nil
    puts "this one"
    @cursor_helper.activate(@menu)
    puts "done"
    @cursor_helper.currently_selected.size.should == 2
    @cursor_helper.currently_selected.search_selected_for(Hero).should_not be_nil

  end

  it "should track paths" do
    @cursor_helper.position.should == 0
    @cursor_helper.path.should == []

    @cursor_helper.move_cursor_down(@menu)
    @cursor_helper.position.should == 1
    @cursor_helper.path.should == []
    
    @cursor_helper.activate(@menu)
    @cursor_helper.position.should == 0
    @cursor_helper.path.should == [1]
  end

  it "should be able to drop the last path element" do
    @cursor_helper.move_cursor_down(@menu)
    @cursor_helper.activate(@menu)
    @cursor_helper.activate(@menu)
    @cursor_helper.path.should == [1,0]
    @cursor_helper.drop_last_path_element
    @cursor_helper.path.should == [1]
  end

  it "should know the names of the current level of menu entries" do
    @cursor_helper.current_menu_entries(@menu).should == ["Status", "Items"]
  end

  it "should handle submenus" do
    @cursor_helper.activate(@menu)
    @cursor_helper.path.should == [0]
    @cursor_helper.current_selected_menu_entry_name(@menu).should == "person a"
    @cursor_helper.path.should == [0]
    @cursor_helper.current_menu_entries(@menu).should == ["person a", "person b"]
  end

  it "should work with inventory selection" do
    @cursor_helper.move_cursor_down(@menu)
    @cursor_helper.current_selected_menu_entry_name(@menu).should == "Items"
    @cursor_helper.activate(@menu)
    @cursor_helper.current_selected_menu_entry_name(@menu).should == "All Items"
    @cursor_helper.move_cursor_down(@menu)
    @cursor_helper.current_selected_menu_entry_name(@menu).should == "Key Items"
    @cursor_helper.activate(@menu)
    @cursor_helper.current_selected_menu_entry_name(@menu).should == "item 1"

    @cursor_helper.activate(@menu)
    @cursor_helper.current_selected_menu_entry_name(@menu).should == "person a"
  end

  it "should work right with stats" do
    @cursor_helper.activate(@menu)
    @cursor_helper.path.should == [0]
    @cursor_helper.move_cursor_down(@menu)
    @cursor_helper.path.should == [0]
    @cursor_helper.current_selected_menu_entry_name(@menu).should == "person b"
  end

  it "should be able to get the name for the current path" do
    @cursor_helper.path.should == []
    @cursor_helper.position.should == 0

    @cursor_helper.current_selected_menu_entry_name(@menu).should == "Status"
    @cursor_helper.move_cursor_down(@menu)
    @cursor_helper.current_selected_menu_entry_name(@menu).should == "Items"
    @cursor_helper.move_cursor_up(@menu)
#    @cursor_helper.current_selected_menu_entry_name(@menu).should == "Status"
#    @cursor_helper.move_cursor_up(@menu)
#    @cursor_helper.current_selected_menu_entry_name(@menu).should == "Load"
  end


  
  it "should be able to activate an item -- cursor resets" do
    @cursor_helper.move_cursor_down(@menu)
    @cursor_helper.activate(@menu)
    @cursor_helper.activate(@menu)
    @cursor_helper.activate(@menu)
    @cursor_helper.current_selected_menu_entry_name(@menu).should == "person a"

    @mock_action.should_receive(:perform)
    @cursor_helper.activate(@menu)
    @cursor_helper.current_selected_menu_entry_name(@menu).should == "person a"

  end

end

