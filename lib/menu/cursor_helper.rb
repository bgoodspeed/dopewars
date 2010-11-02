# To change this template, choose Tools | Templates
# and open the template in the editor.

class CursorHelper
  include Rubygame

  attr_reader :position, :depth, :path, :currently_selected
  def initialize(dims)
    @cursor = Surface.new(dims)
    @current_color = :blue
    reset_indices
  end



  def reset_indices
    @position = 0
    @depth = 0
    @path = []
    reset_selections
  end

  def reset_selections
    @currently_selected = Selections.new
  end

  def selected_amongst(sections)
    current_section_in(sections).section_by_index(@position)
  end


  def path
    @path.clone
  end

  def move_cursor_up(menu)
    move_cursor(-1, menu.size_at(path, @currently_selected))
  end
  def move_cursor_down(menu)
    move_cursor(1, menu.size_at(path, @currently_selected))
  end


  def drop_last_path_element
    @path = @path.slice(0,@path.size - 1)
  end

  def activate(menu)
    @depth += 1
    old_position = @position
    @path.push(@position)
    @position = 0
    e = menu.navigate_path_to_select(path, @currently_selected)
    puts "selecting #{e}"
    add_currently_selected e

    if menu.any_satisfiable_and_selected?(@currently_selected)
      action_to_take = menu.satisfiable_and_selected(@currently_selected).first
      action_to_take.invoke(@currently_selected)

      @currently_selected.drop_last
      drop_last_path_element
    end
#    if path.size > 1 && !menu.element_at(path.first, @currently_selected).ready_with?(path.size - 1)
#      rv = menu.navigate_path(path, @position, @currently_selected)
#      add_currently_selected rv
#    end
#
#    if menu.ready_for_activation_with?(path, @position, @currently_selected)
#
#      action = menu.element_at(path.first, @currently_selected).action
#      action.invoke(@currently_selected)
#      reset_indices
#    end

  end

  def current_selected_menu_entry_name(menu)
    menu.element_name_at(path, @position, @currently_selected)
  end

  def current_menu_entries(menu)
    menu.navigate_path(path).element_names(@currently_selected)
  end




  def reduce_only_to_zero(v)
    rv = v - 1
    rv < 0 ? 0 : rv
  end

  def cancel
    puts "before cancel path was size: #{@path.size}"
    @path.shift
    puts "after cancel path was size: #{@path.size}"
    @depth = reduce_only_to_zero(@depth)
  end

  def clamping_delta(value, maxsize, delta=1)
    (value + delta) % maxsize
  end

  def move_cursor(dir, maxsize)
    @position = clamping_delta(@position, maxsize, dir)
  end

  def position_at_depth(d)
    if d >= @depth
      @position
    else
      @path[d]
    end
  end

  def add_currently_selected(s)
    @currently_selected << s
  end


  def path_element_at_index(idx)
    #([@position] + @path)[idx]
    ([@position] + @path)[idx]
  end


  def should_display_submenu_for?(index, depth)
    #puts "in should display submenu we have path size #{@path.join(',')}=>#{@path.size} vs depth: #{depth}"
    (depth < @path.size) && @path.first == index
  end

  def selections_made
    @path.size - 1
  end

  def selector_menus_to_draw_at_depth(depth, needed)
    needed - selections_made
  end
  def color_for_current_section_cursor
    @current_color
  end

  def draw_at_depth(layer, menu_layer_config, game, active_section) #TODO make active section go away
    #TODO use the right depth in the config
    draw(layer, menu_layer_config.main_cursor.cursor_offsets_at(position, game, active_section))
  end

  def draw(layer, offsets)
    @cursor.fill(color_for_current_section_cursor)
    @cursor.blit(layer, offsets)

  end
end
