#TODO this class should be broken up
class MenuHelper
  include Rubygame

  def initialize(screen, layer,text_helper, sections, cursor_x, cursor_y, cursor_main_color=:blue, cursor_inactive_color=:white)
    @layer = layer
    @text_rendering_helper = text_helper
    @screen = screen
    replace_sections(sections)
  end

  def reset_indices
    @menu_sections.reset_indices
  end

  def current_menu_entries
    @menu_sections.section_names
  end

  def current_selected_menu_entry_name
    @menu_sections.cursor_selected_entry_name
  end

  def move_cursor_down
    move_cursor(1)
  end

  def move_cursor(dir)
    @menu_sections.move_cursor(dir)
  end

  def move_cursor_up
    move_cursor(-1)
  end
  def enter_current_cursor_location(game)
    @menu_sections.activate(game)
  end
  def cancel_action
    @menu_sections.cancel
  end
  def replace_sections(sections)
    @menu_sections = sections
  end
  #TODO this is odd to have in the api for this class... reconsider
  def render_text_to_layer(text, conf)
    @text_rendering_helper.render_lines_to_layer( text, conf)
  end
  def render_text_to(surface, text, conf)
    @text_rendering_helper.render_lines_to(surface, text, conf)
  end
  def draw(menu_layer_config, game)
    @menu_sections.draw(menu_layer_config, game, @text_rendering_helper, @layer, @screen)
#    #render_text_to_layer( @text_lines, menu_layer_config.main_menu_text)
#    #@cursor.fill(color_for_current_section_cursor)
#    if @show_section
#      render_text_to_layer(active_section.text_contents, menu_layer_config.section_menu_text)
#      conf = menu_layer_config.in_section_cursor
#
#      if subsection_active?(@section_position)
#        surf = active_subsection.details
#        conf = menu_layer_config.in_subsection_cursor
#
#        surf.blit(@layer, menu_layer_config.details_inset_on_layer) if surf
#        @cursor.fill(:black)
#
#        if @needs_option
#          conf = menu_layer_config.in_option_section_cursor
#          optsurf = active_subsection.surface_for(@subsection_position)
#          optsurf.blit(@layer, menu_layer_config.options_inset_on_layer) if optsurf
#          @cursor.blit(@layer, conf.cursor_offsets_at(@option_position, game, active_subsection))
#        else
#          @cursor.blit(@layer, conf.cursor_offsets_at(@subsection_position, game, active_subsection))
#        end
#      else
#        @cursor.blit(@layer, conf.cursor_offsets_at(@section_position, game, active_subsection))
#      end
#    else
#
#      conf = menu_layer_config.main_cursor
#      puts "top level: #{active_section}"
      #@cursor.blit(@layer, conf.cursor_offsets_at(@cursor_position, game, active_section))
#    end
#    @layer.blit(@screen, menu_layer_config.layer_inset_on_screen)
  end

end
