# To change this template, choose Tools | Templates
# and open the template in the editor.

class MenuSections
  include Rubygame
  extend Forwardable

  def_delegators :@cursor_helper, :move_cursor
  
  def initialize(cursor_helper, section_depth, sections_offset, sections)
    @sections = sections
    @section_depth = section_depth
    @cursor_helper = cursor_helper
    @activated = false
    @sections_offset = sections_offset
  end

  def activate(game)
    #TODO maybe check here for the type and required depth?
    @activated = true
    @cursor_helper.activate
  end

  def section_by_index(idx)
    if @sections.is_a?(MenuSections)
      @sections.section_by_index(idx)
    else
      @sections[idx]
    end
    
  end

  def size
    @sections.size
  end

  def cancel
    @cursor_helper.cancel
  end

  def name
    @sections.first.text
  end

  def cursor_selected_entry_name
    @cursor_helper.selected_amongst(self).name
  end
  def active_section
    @sections[@cursor_helper.position]
  end

  def color_for_current_section_cursor
    :blue #TODO update this
  end

  def text
    @sections.collect { |s| s.text }
  end

  def section_names
    text
  end

  def reset_indices
    @cursor_helper.reset_indices
  end

  def move_cursor(dir)
    @cursor_helper.move_cursor(dir, self)
  end

  def section_within_depth(d)
    @section_depth <= d
  end

  def draw(menu_layer_config, game, text_rendering_helper, layer, screen)
    return unless section_within_depth(@cursor_helper.depth)

    text_rendering_helper.render_lines_to_layer( text, @sections_offset)
    #TODO move cursor drawing into menu layer/menu helper
    @cursor_helper.draw_at_depth(layer, menu_layer_config, game, active_section)
    pos_at_depth = @sections[@cursor_helper.position_at_depth(@section_depth)]
    if pos_at_depth.has_subsections?
      pos_at_depth.draw(menu_layer_config, game, text_rendering_helper, layer, screen)
    end
    layer.blit(screen, menu_layer_config.layer_inset_on_screen)
    
  end



end
