
class CoordinateHelper
  attr_accessor :px, :py, :ax, :ay, :vx, :vy

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

  def get_coord_set(is_world)
    x1 = @universe.x_offset_for_world(base_x)
    x2 = @universe.x_offset_for_world(max_x)

    y1 = @universe.y_offset_for_world(base_y)
    y2 = @universe.y_offset_for_world(max_y)


    unless is_world
      x1 = @universe.x_offset_for_interaction(base_x)
      x2 = @universe.x_offset_for_interaction(max_x)

      y1 = @universe.y_offset_for_interaction(base_y)
      y2 = @universe.y_offset_for_interaction(max_y)
      
    end

    TileCoordinateSet.new(x1,x2, y1,y2 )
  end
  def world_coords
    get_coord_set(true)
  end

  def interact_coords
    get_coord_set(false)
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

  def clamp_to_tile_restrictions_on(interp, new_values, old_values, y_coord_pairs, x_coord_pairs)
    rv = false

    if new_values[0] != old_values[0]
      rv = true if check_corners(interp, *y_coord_pairs)
    end
    if new_values[1] != old_values[1]
      rv = true if check_corners(interp, *x_coord_pairs)
    end
    rv

  end

  def clamp_to_tile_restrictions_on_y(interp, coords)
    clamp_to_tile_restrictions_on(interp, *y_args(coords))
  end

  def bg_tile_ys
    [@bg_tile_coords.miny, @bg_tile_coords.maxy]
  end
  def bg_tile_xs
    [@bg_tile_coords.minx, @bg_tile_coords.maxy]
  end

  def coord_xs(coords)
    [coords.minx, coords.maxx]
  end

  def coord_ys(coords)
    [coords.miny, coords.maxy]
  end

  def y_args(coords)
    [ coord_ys(coords),
      [bg_tile_ys],
      [coords.maxx, coords.miny, coords.minx, coords.miny],
      [coords.maxx, coords.maxy, coords.minx, coords.maxy]

    ]
  end
  def x_args(coords)
    [ coord_xs(coords),
      bg_tile_xs,
      [coords.minx, coords.miny, coords.minx, coords.maxy],
      [coords.maxx, coords.miny, coords.maxx, coords.maxy]
    ]
  end

  def clamp_to_tile_restrictions_on_x(interp, coords)
    clamp_to_tile_restrictions_on(interp, *x_args(coords))
  end

  def blocking(col)
    col.select do |npc|
      npc.is_blocking?
    end
  end

  

  def hits(npcs)
    npcs.select do |npc|
      (npc.collides_on_x?(base_x) or npc.collides_on_x?(max_x)) and
       (npc.collides_on_y?(base_y) or npc.collides_on_y?(max_y))
    end
  end
  def hit_blocking_npcs(npcs)
    blocking(hits(npcs))
  end


  def candidate_npcs(who=nil)
    @universe.current_world.npcs
  end

  def topo
    @universe.current_world.topo_interpreter
  end

  def interaction
    @universe.current_world.interaction_interpreter
  end


  def check_collisions(c)
    !c.empty?
  end
  def check_axis(collisions, axis)
    if axis == :x
      c1 = clamp_to_tile_restrictions_on_x(topo, world_coords)
      c2 = clamp_to_tile_restrictions_on_x(interaction, interact_coords)
    else
      c1 = clamp_to_tile_restrictions_on_y(topo, world_coords)
      c2 = clamp_to_tile_restrictions_on_y(interaction, interact_coords)
    end
    c1 or c2 or check_collisions(collisions)
  end


  def update_pos( dt, who=nil )
    dx = @vx * dt
    dy = @vy * dt

    @px += dx
    x_collisions = hit_blocking_npcs(candidate_npcs(who))
    @py += dy
    y_collisions = hit_blocking_npcs(candidate_npcs(who)) - x_collisions
    clamp_to_world_dimensions

    @px -= dx if check_axis(x_collisions, :x)
    @py -= dy if check_axis(y_collisions, :y)

    cols = hits(candidate_npcs(who))
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
