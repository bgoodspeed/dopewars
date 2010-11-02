
class MenuLayerConfig
  attr_accessor :main_menu_text, :section_menu_text, :in_section_cursor,
    :main_cursor, :layer_inset_on_screen, :details_inset_on_layer,
    :options_inset_on_layer, :in_subsection_cursor, :in_option_section_cursor

  def selector_menu_text_config_at_depth(d)
    TextRenderingConfig.new(3 * @@MENU_TEXT_INSET + d * @@MENU_TEXT_WIDTH + @@MENU_LINE_SPACING, 0, @@MENU_TEXT_INSET, @@MENU_LINE_SPACING)
  end
end
