
class MenuLayer < AbstractLayer
  include FontLoader #TODO unify resource loading
  attr_accessor :active

  alias_method :active?, :active
  alias_method :visible, :active
  alias_method :toggle_visibility, :toggle_activity

  extend Forwardable
  def_delegators :@menu_helper, :enter_current_cursor_location, :move_cursor_down,
    :move_cursor_up, :cancel_action, :reset_indices

  def initialize(screen, game)
    super(screen, (screen.w) - 2*@@MENU_LAYER_INSET, (screen.h) - 2*@@MENU_LAYER_INSET)
    @layer.fill(:red)
    @layer.alpha = 192
    @game = game
    @menu_helper = MenuHelper.new(screen, @layer, @text_rendering_helper, [], @@MENU_LINE_SPACING,@@MENU_LINE_SPACING)
  end

  def menu_sections_for(chars)
    [MenuSection.new("Status", chars.collect {|m| StatusDisplayAction.new(m, @menu_helper)}),
      MenuSection.new("Inventory", [InventoryDisplayAction.new("All Items", @game, @menu_helper), KeyInventoryDisplayAction.new("Key Items", @game, @menu_helper), SortInventoryAction.new("Sort", @game, @menu_helper)]),
      MenuSection.new("Levelup", chars.collect {|m| LevelUpAction.new(m, @menu_helper)}),
      MenuSection.new("Equip", chars.collect {|m| UpdateEquipmentAction.new(m, @menu_helper, @game)}),
      MenuSection.new("Save", [SaveMenuAction.new("Slot 1")]),
      MenuSection.new("Load", [LoadMenuAction.new("Slot 1")])
    ]
  end


  def rebuild_menu_sections
    menu_sections_for(@game.party_members)
  end
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

  def draw()
    @layer.fill(:red)
    @menu_helper.replace_sections(rebuild_menu_sections)
    @menu_helper.draw(menu_layer_config, @game)
  end
end