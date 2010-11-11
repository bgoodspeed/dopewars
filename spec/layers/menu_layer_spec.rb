
require 'spec/rspec_helper'

describe MenuLayer do
  include DomainMocks
  include MethodDefinitionMatchers
  include DelegationMatchers
  
  before(:each) do
    @screen = mock_screen
    @game = mock_game
    @layer = MenuLayer.new(@screen, @game)
  end

  it "should be inactive by default" do
    @layer.active.should be_false
  end


  it "should rebuild menus" do
    @layer.rebuild_menu
    @layer.menu.should_not be_nil
  end

  it "should delegate cursor commands" do
    @layer.rebuild_menu
    @layer.should delegate_to({:move_cursor_up => [@layer.menu]}, {:cursor_helper => :move_cursor_up})
    @layer.should delegate_to({:move_cursor_down => [@layer.menu]}, {:cursor_helper => :move_cursor_down})
    @layer.should delegate_to({:enter_current_cursor_location => [@layer.menu]}, {:cursor_helper => :activate})
    @layer.should delegate_to({:current_selected_menu_entry_name => [@layer.menu]}, {:cursor_helper => :current_selected_menu_entry_name})
    @layer.should delegate_to({:current_menu_entries => [@layer.menu]}, {:cursor_helper => :current_menu_entries})
  end


  it "should define menu api" do
    @layer.should define(:move_cursor_up)
    @layer.should define(:move_cursor_down)
    @layer.should define(:enter_current_cursor_location)
  end



  it "should make menu layer configs" do
    @layer.menu_layer_config.should be_an_instance_of(MenuLayerConfig)
  end

  it "should make sectin text configs" do
    @layer.section_text_rendering_config(0).should be_an_instance_of(TextRenderingConfig)
  end

  it "should be drawable" do
    expect_blitted(@layer.layer)
    @layer.draw
  end

end
