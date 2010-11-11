
class MenuLayer < AbstractLayer
  attr_accessor :active

  alias_method :active?, :active
  alias_method :visible, :active
  alias_method :toggle_visibility, :toggle_activity

  extend Forwardable

  def_delegators :@cursor_helper, :reset_indices
  attr_reader :text_rendering_helper
  attr_accessor :cursor_helper, :layer
  def initialize(screen, game)
    super(screen, (screen.w) - 2*@@MENU_LAYER_INSET, (screen.h) - 2*@@MENU_LAYER_INSET)
    @layer.fill(:red)
    @layer.alpha = 192
    @game = game
    @cursor_helper = CursorHelper.new(cursor_dims)
  #  @menu_helper = MenuHelper.new(screen, @layer, @text_rendering_helper, [], @@MENU_LINE_SPACING,@@MENU_LINE_SPACING)

  end



  def cursor_dims
    [@@MENU_LINE_SPACING,@@MENU_LINE_SPACING]
  end

  def rebuild_menu
    filter_selector = InventoryFilterMenuSelector.new(@game)
    equipment_slot_selector = EquipmentSlotMenuSelector.new(@game)

    @menu = TaskMenu.new(@game, [
        StatLineInfoMenuAction.new(@game),
        UseItemMenuAction.new(@game),
        LevelUpStatMenuAction.new(@game),
        EquipItemInMemberSlotMenuAction.new(@game),
        MissionInfoMenuAction.new(@game),
        SaveGameMenuAction.new(@game),
        LoadGameMenuAction.new(@game)
      ])

  end

  def menu
    @menu
  end

  def move_cursor_up(e)
    @cursor_helper.move_cursor_up(menu)
  end
  def move_cursor_down(e)
    @cursor_helper.move_cursor_down(menu)
  end

  def enter_current_cursor_location(e)
    @cursor_helper.activate(menu)
  end
  def current_selected_menu_entry_name(e=nil)
    @cursor_helper.current_selected_menu_entry_name(menu)
  end
  def current_menu_entries(e=nil)
    @cursor_helper.current_menu_entries(menu)
  end

  def section_text_rendering_config(depth)
    TextRenderingConfig.new(2 * @@MENU_TEXT_INSET + 4*@@MENU_TEXT_WIDTH, 0, depth * @@MENU_TEXT_INSET, @@MENU_LINE_SPACING)
  end

  def menu_layer_config

    mlc = MenuLayerConfig.new
    mlc.main_menu_text = TextRenderingConfig.new(@@MENU_TEXT_INSET, 0, @@MENU_TEXT_INSET, @@MENU_LINE_SPACING)
    mlc.section_menu_text = TextRenderingConfig.new(3 * @@MENU_TEXT_INSET + @@MENU_TEXT_WIDTH + @@MENU_LINE_SPACING, 0, @@MENU_TEXT_INSET, @@MENU_LINE_SPACING)
    mlc.in_subsection_cursor =     section_text_rendering_config(2)
    mlc.in_option_section_cursor = section_text_rendering_config(3)
    mlc.in_section_cursor = TextRenderingConfig.new(2 * @@MENU_TEXT_INSET + 4*@@MENU_TEXT_WIDTH, 0, @@MENU_TEXT_INSET, @@MENU_LINE_SPACING)
    mlc.main_cursor = TextRenderingConfig.new(2 * @@MENU_TEXT_INSET + @@MENU_TEXT_WIDTH, 0, @@MENU_TEXT_INSET, @@MENU_LINE_SPACING)
    mlc.layer_inset_on_screen = [@@MENU_LAYER_INSET,@@MENU_LAYER_INSET]
    mlc.details_inset_on_layer = [@@MENU_DETAILS_INSET_X, @@MENU_DETAILS_INSET_Y]
    mlc.options_inset_on_layer = [@@MENU_OPTIONS_INSET_X, @@MENU_OPTIONS_INSET_Y]
    mlc
  end

  def draw()
    @layer.fill(:red)
#    @menu_helper.replace_sections(rebuild_menu_sections)
    # @menu_helper.draw(menu_layer_config, @game)
    rebuild_menu
    menu.draw(menu_layer_config, @cursor_helper.path, @cursor_helper.currently_selected)
    @cursor_helper.draw_at_depth(@layer, menu_layer_config, @game, nil)
    @layer.blit(@screen, menu_layer_config.layer_inset_on_screen)
  end
end