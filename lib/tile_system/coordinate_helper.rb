
class CoordinateHelper
  attr_accessor :px, :py

  def initialize(position, key,universe,  max_speed=400, accel=1200, slowdown=800)
    @hero_x_dim = position.dimension.x
    @hero_y_dim = position.dimension.y
    @universe = universe
    @keys = key
    @px, @py = position.position.x, position.position.y # Current Position
    @vx, @vy = 0, 0 # Current Velocity
    @ax, @ay = 0, 0 # Current Acceleration
    @max_speed = max_speed # Max speed on an axis
    @accel = accel # Max Acceleration on an axis
    @slowdown = slowdown # Deceleration when not accelerating
    update_tile_coords
  end

  def get_position
    [@px,@py]
  end

  def world_coords
    TileCoordinateSet.new( @universe.current_world.x_offset_for_world(base_x),
      @universe.current_world.x_offset_for_world(max_x),
      @universe.current_world.y_offset_for_world(base_y ),
      @universe.current_world.y_offset_for_world(max_y) )
  end

  def interact_coords
    TileCoordinateSet.new( @universe.current_world.x_offset_for_interaction(base_x),
      @universe.current_world.x_offset_for_interaction(max_x),
      @universe.current_world.y_offset_for_interaction(base_y ),
      @universe.current_world.y_offset_for_interaction(max_y) )
  end

  def max_x
    @px
  end
  def max_y
    @py
  end

  def base_x
    @px -  @hero_x_dim
  end

  def base_y
    @py -  @hero_y_dim
  end
 def collides_on_x?(x)
    (@px - x).abs < x_ext
  end
  def collides_on_y?(y)
    (@py - y).abs < y_ext
  end


  def update_tile_coords
    @bg_tile_coords = world_coords
    @interaction_tile_coords = interact_coords
  end
  def update_accel
    x, y = 0,0

    x -= 1 if @keys.include?( :left )
    x += 1 if @keys.include?( :right )
    y -= 1 if @keys.include?( :up ) # up is down in screen coordinates
    y += 1 if @keys.include?( :down )

    # Scale to the acceleration rate. This is a bit unrealistic, since
    # it doesn't consider magnitude of x and y combined (diagonal).
    x *= @accel
    y *= @accel

    @ax, @ay = x, y
  end
  def update_vel( dt )
    @vx = update_vel_axis( @vx, @ax, dt )
    @vy = update_vel_axis( @vy, @ay, dt )
  end
  def update_vel_axis( v, a, dt )

    # Apply slowdown if not accelerating.
    if a == 0
      if v > 0
        v -= @slowdown * dt
        v = 0 if v < 0
      elsif v < 0
        v += @slowdown * dt
        v = 0 if v > 0
      end
    end

    # Apply acceleration
    v += a * dt

    # Clamp speed so it doesn't go too fast.
    v = @max_speed if v > @max_speed
    v = -@max_speed if v < -@max_speed

    return v
  end
  def x_ext
    @hero_x_dim/2
  end
  def y_ext
    @hero_y_dim/2
  end
  def clamp_to_world_dimensions
    minx = @px - x_ext
    maxx = @px + x_ext
    miny = @py - y_ext
    maxy = @py + y_ext
    @px = x_ext if minx < 0
    @px = @@BGX - x_ext if maxx > @@BGX #TODO this should come from the current world

    @py = y_ext if miny < 0
    @py = @@BGY - y_ext if maxy > @@BGY
  end
  def check_corners(interp, x1, y1, x2, y2)
    c1 = interp.can_walk_at?(x1,y1)
    c2 = interp.can_walk_at?(x2,y2)

    unless c1 and c2
      return true
    end
    false
  end
  def clamp_to_tile_restrictions_on_y(interp, new_bg_tile_coords)
    rv = false

    if new_bg_tile_coords.miny != @bg_tile_coords.miny
      rv = true if check_corners(interp, new_bg_tile_coords.maxx, new_bg_tile_coords.miny, new_bg_tile_coords.minx, new_bg_tile_coords.miny)
    end
    if new_bg_tile_coords.maxy != @bg_tile_coords.maxy
      rv = true if check_corners(interp, new_bg_tile_coords.maxx, new_bg_tile_coords.maxy, new_bg_tile_coords.minx, new_bg_tile_coords.maxy)
    end
    rv
  end
  def clamp_to_tile_restrictions_on_x(interp, new_bg_tile_coords)
    rv = false

    if new_bg_tile_coords.minx != @bg_tile_coords.minx
      rv = true if check_corners(interp, new_bg_tile_coords.minx, new_bg_tile_coords.miny, new_bg_tile_coords.minx, new_bg_tile_coords.maxy)
    end

    if new_bg_tile_coords.maxx != @bg_tile_coords.maxx
      rv = true if check_corners(interp, new_bg_tile_coords.maxx, new_bg_tile_coords.miny, new_bg_tile_coords.maxx, new_bg_tile_coords.maxy)
    end

    rv
  end
  def blocking(col)
    col.select do |npc|
      npc.is_blocking?
    end
  end
  def x_hits(npcs)
    npcs.select do |npc|
      npc.collides_on_x?(base_x) or npc.collides_on_x?(max_x)
    end
  end
  def y_hits(npcs)
    npcs.select do |npc|
      npc.collides_on_y?(base_y) or npc.collides_on_y?(max_y)
    end
  end
  def hit_blocking_npcs_on_x(npcs)
    blocking(y_hits(x_hits(npcs)))
  end
  def hit_blocking_npcs_on_y(npcs)
    blocking(y_hits(x_hits(npcs)))
  end


  def candidate_npcs(who=nil)
    @universe.current_world.npcs
  end

  def update_pos( dt, who=nil )
    dx = @vx * dt
    dy = @vy * dt

    @px += dx
    x_collisions = hit_blocking_npcs_on_x(candidate_npcs(who))
    @py += dy
    y_collisions = hit_blocking_npcs_on_x(candidate_npcs(who)) - x_collisions
    clamp_to_world_dimensions

    topo = @universe.current_world.topo_interpreter
    interact = @universe.current_world.interaction_interpreter
    new_bg_tile_coords = world_coords
    new_interaction_tile_coords = interact_coords

    @px -= dx if clamp_to_tile_restrictions_on_x(topo, new_bg_tile_coords) or clamp_to_tile_restrictions_on_x(interact, new_interaction_tile_coords) or !x_collisions.empty?
    @py -= dy if clamp_to_tile_restrictions_on_y(topo, new_bg_tile_coords) or clamp_to_tile_restrictions_on_y(interact, new_interaction_tile_coords) or !y_collisions.empty?

    cols = y_hits(x_hits(candidate_npcs(who)))
    handle_collision(cols) unless cols.empty?
    update_tile_coords
  end

  def handle_collision(cols)
    monsters = cols.select { |col| col.class == Monster}
    return if monsters.empty?
    monster = monsters[0]
    monster.interact(@universe.game, @universe, @universe.game.player)
  end
end
