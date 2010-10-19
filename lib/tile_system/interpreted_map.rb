
class InterpretedMap
  attr_reader :topo_map, :pallette

  extend Forwardable
  def_delegators :@topo_map, :left_side, :right_side, :bottom_side, :top_side,
    :update, :x_offset_for_world, :y_offset_for_world, :data_at

  def initialize(topo_map, pallette)
    @topo_map = topo_map
    @pallette = pallette
  end
  def blit_foreground(screen,px, py)
    @topo_map.blit_foreground(@pallette, screen,px, py)
  end
  def blit_to(surface)
    @topo_map.blit_to(@pallette, surface)
  end

  def [](key)
    @pallette[key]
  end

  def interpret(tilex, tiley)
    self[data_at(tilex,tiley)]
  end

  def can_walk_at?(xi,yi)
    d = @topo_map.data_at(xi,yi)
    tile = self[d]
    return true if tile.nil?

    !tile.is_blocking?
  end

  def replace_pallette(orig_interpreter)
    @pallette = orig_interpreter.pallette
  end

  include JsonHelper
  def json_params
    [ @topo_map, nil]
  end
end
