# To change this template, choose Tools | Templates
# and open the template in the editor.

class CursorHelper
  include Rubygame

  attr_reader :position, :depth
  def initialize(dims)
    @cursor = Surface.new(dims)
    @current_color = :blue
    reset_indices
  end
  def reset_indices
    @position = 0
    @depth = 0
    @path = []

  end
  
  def selected_amongst(sections)
    current_section_in(sections).section_by_index(@position)
  end

  def activate
    @depth += 1
    @path = @path + [@position] 
    @position = 0
  end

  def reduce_only_to_zero(v)
    rv = v - 1
    rv < 0 ? 0 : rv
  end

  def cancel
    @path.shift
    @depth = reduce_only_to_zero(@depth)
  end

  def clamping_delta(value, maxsize, delta=1)
    (value + delta) % maxsize
  end

  def current_section_in(sections)
    rv = sections
    (@path).each {|p|
      rv = rv.section_by_index(p)
    }
    rv
  end

  def move_cursor(dir, sections)
    maxsize = current_section_in(sections).size
    @position = clamping_delta(@position, maxsize, dir)
    puts "cursor is now at: #{@position} of #{maxsize} in dir #{dir}"
  end

  def position_at_depth(d)
    if d >= @depth
      @position
    else
      @path[d]
    end
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
