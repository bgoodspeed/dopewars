#!/bin/env ruby

# One way of making an object start and stop moving gradually:
# make user input affect acceleration, not velocity.

require 'rubygems'
require 'rubygame'

require 'lib/font_loader'
require 'lib/topo_map'
require 'lib/hud'

# Include these modules so we can type "Surface" instead of
# "Rubygame::Surface", etc. Purely for convenience/readability.

include Rubygame
include Rubygame::Events
include Rubygame::EventActions
include Rubygame::EventTriggers

@@BGX = 1280
@@BGY = 960

class Universe
  attr_reader :worlds, :current_world, :dialog_layer

  def initialize(worlds, dialog_layer)
    raise "must have at least one world" if worlds.empty?
    @current_world = worlds[0]
    @worlds = worlds
    @dialog_layer = dialog_layer
  end

  def world_by_index(idx)
    @worlds[idx]
  end

  def set_current_world(world)
    @current_world = world
  end

  def set_current_world_by_index(idx)
    set_current_world(world_by_index(idx))
  end
end


class WorldState
  attr_reader :topo_map, :topo_pallette, :terrain_map, :terrain_pallette,
              :interaction_map, :interaction_pallette, :npcs,
              :background_surface
            
  def initialize(topomap, topopal, terrainmap, terrainpal, interactmap, interactpal, npcs, bgsurface)
    @topo_map = topomap
    @topo_pallette = topopal
    @terrain_map = terrainmap
    @terrain_pallette = terrainpal
    @interaction_map = interactmap
    @interaction_pallette = interactpal
    @background_surface = bgsurface
    @npcs = npcs
  end


end

class KeyHolder
  def initialize
    @keys = []
  end
  def include?(other)
    @keys.include?(other)
  end
  def empty?
    @keys.empty?
  end

  def delete_key(key)
    @keys -= [key]
  end
  def add_key(key)
    @keys += [key]
  end
  
end

class AlwaysDownMonsterKeyHolder < KeyHolder
  @@DOWNKEY = :always_down
  def initialize(key=@@DOWNKEY)
    super()
    add_key(key)
  end
end
class AnimationHelper
  @@FRAME_SWITCH_THRESHOLD = 0.40
  @@ANIMATION_FRAMES = 4

  def current_frame
    @animation_frame
  end

  def initialize(key_holder, animation_frames=@@ANIMATION_FRAMES)
    @key_holder = key_holder
    @animation_counter = 0
    @animation_frame = 0
    @animation_frames = animation_frames
  end
  def update_animation(dt)
    @animation_counter += dt
    if @animation_counter > @@FRAME_SWITCH_THRESHOLD
      @animation_counter = 0
      unless @key_holder.empty?
        @animation_frame = (@animation_frame + 1) % @animation_frames
        yield @animation_frame
      end
    end

  end
  
end

class InteractionHelper
  @@INTERACTION_DISTANCE_THRESHOLD = 80 #XXX tweak this, currently set to 1/2 a tile

  attr_accessor :facing
  def initialize(player, universe)
    @player = player
    @universe = universe
    @facing = :down
  end

  def interact_with_facing(px,py)
    if @universe.dialog_layer.visible
      puts "confirming/closing/paging dialog"
      @universe.dialog_layer.displayed
      return #XXX check this return policy (ie currently first matching action is the only one run
    end

    puts "you are facing #{@facing}"
    tilex = @universe.current_world.topo_map.x_offset_for_world(px)
    tiley = @universe.current_world.topo_map.y_offset_for_world(py)
    this_tile_interacts = @universe.current_world.interaction_pallette[@universe.current_world.interaction_map.data_at(tilex,tiley)]
    facing_tile_interacts = false

    if this_tile_interacts
      puts "you can interact with the current tile"
      this_tile_interacts.activate(@player, @universe.current_world, tilex, tiley)
      return
    end

    if @facing == :down
      facing_tilex = tilex
      facing_tiley = tiley + 1
      facing_tile_dist = (@universe.current_world.interaction_map.top_side(tiley + 1) - py).abs
    end
    if @facing == :up
      facing_tilex = tilex
      facing_tiley = tiley - 1
      facing_tile_dist = (@universe.current_world.interaction_map.bottom_side(tiley - 1) - py).abs
    end
    if @facing == :left
      facing_tilex = tilex - 1
      facing_tiley = tiley
      facing_tile_dist = (@universe.current_world.interaction_map.right_side(tilex - 1) - px).abs
    end
    if @facing == :right
      facing_tilex = tilex + 1
      facing_tiley = tiley
      facing_tile_dist = (@universe.current_world.interaction_map.left_side(tilex + 1) - px).abs
    end

    facing_tile_interacts = @universe.current_world.interaction_pallette[@universe.current_world.interaction_map.data_at(facing_tilex, facing_tiley)]
    facing_tile_close_enough = facing_tile_dist < @@INTERACTION_DISTANCE_THRESHOLD

    if facing_tile_close_enough and facing_tile_interacts
      puts "you can interact with the facing tile in the #{@facing} direction, it is at #{facing_tilex} #{facing_tiley}"
      facing_tile_interacts.activate(@player, @universe.current_world, facing_tilex, facing_tiley) #@interactionmap, facing_tilex, facing_tiley, @bgsurface, @topomap, @topo_pallette
      return
    end

    interactable_npcs = @universe.current_world.npcs.select {|npc| npc.nearby?(px,py, @@INTERACTION_DISTANCE_THRESHOLD, @@INTERACTION_DISTANCE_THRESHOLD)  }
    unless interactable_npcs.empty?
      puts "you can interact with the npc: #{interactable_npcs[0]}"
      npc = interactable_npcs[0] #TODO what if there are multiple npcs to interact w/? one at a time? all of them?
      npc.interact(@universe, @player)
    end

  end
end


class CoordinateHelper
  attr_accessor :px, :py

  def initialize(px,py, key,universe, hero_x_dim, hero_y_dim)
     @hero_x_dim, @hero_y_dim =  hero_x_dim, hero_y_dim
    @universe = universe
    @keys = key
    @px, @py = px, py # Current Position
    @vx, @vy = 0, 0 # Current Velocity
    @ax, @ay = 0, 0 # Current Acceleration
    @max_speed = 400.0 # Max speed on an axis
    @accel = 1200.0 # Max Acceleration on an axis
    @slowdown = 800.0 # Deceleration when not accelerating
  end

  def update_tile_coords
    @mintilex = @universe.current_world.topo_map.x_offset_for_world(@px - x_ext)
    @maxtilex = @universe.current_world.topo_map.x_offset_for_world(@px + x_ext)
    @mintiley = @universe.current_world.topo_map.y_offset_for_world(@py - y_ext)
    @maxtiley = @universe.current_world.topo_map.y_offset_for_world(@py + y_ext)
  end
  def x_ext
    @hero_x_dim/2
  end
  def y_ext
    @hero_y_dim/2
  end
  # Update the acceleration based on what keys are pressed.
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


  # Update the velocity based on the acceleration and the time since
  # last update.
  def update_vel( dt )
    @vx = update_vel_axis( @vx, @ax, dt )
    @vy = update_vel_axis( @vy, @ay, dt )
  end


  # Calculate the velocity for one axis.
  # v = current velocity on that axis (e.g. @vx)
  # a = current acceleration on that axis (e.g. @ax)
  #
  # Returns what the new velocity (@vx) should be.
  #
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

  def clamp_to_world_dimensions

    minx = @px - x_ext
    maxx = @px + x_ext
    miny = @py - y_ext
    maxy = @py + y_ext
    @px = x_ext if minx < 0
    @px = @@BGX - x_ext if maxx > @@BGX

    @py = y_ext if miny < 0
    @py = @@BGY - y_ext if maxy > @@BGY
  end

  def clamp_to_tile_restrictions_on_y(tp, new_mintilex, new_mintiley, new_maxtilex, new_maxtiley)
    rv = false

    if new_mintiley != @mintiley
      bottom_right = @universe.current_world.terrain_map.data_at(new_maxtilex, new_mintiley)
      bottom_left = @universe.current_world.terrain_map.data_at(new_mintilex, new_mintiley)

      unless tp[bottom_left] and tp[bottom_right]
        rv = true
      end
    end
    if new_maxtiley != @maxtiley

      top_right = @universe.current_world.terrain_map.data_at(new_maxtilex, new_maxtiley)
      top_left = @universe.current_world.terrain_map.data_at(new_mintilex, new_maxtiley)

      unless tp[top_left] and tp[top_right]
        rv = true
      end

    end
    rv
  end
  def clamp_to_tile_restrictions_on_x(tp, new_mintilex, new_mintiley, new_maxtilex, new_maxtiley)
    rv = false
    
    if new_mintilex != @mintilex
      bottom_left = @universe.current_world.terrain_map.data_at(new_mintilex, new_mintiley)
      top_left = @universe.current_world.terrain_map.data_at(new_mintilex, new_maxtiley)
      unless tp[bottom_left] and tp[top_left]
        rv = true
      end
    end

    if new_maxtilex != @maxtilex
      bottom_right = @universe.current_world.terrain_map.data_at(new_maxtilex, new_mintiley)
      top_right = @universe.current_world.terrain_map.data_at(new_maxtilex, new_maxtiley)

      unless tp[bottom_right] and tp[top_right]
        rv = true
      end
    end

    rv
  end

  

  def update_pos( dt )
    dx = @vx * dt
    dy = @vy * dt
    @px += dx
    @py += dy

    clamp_to_world_dimensions

    tp = @universe.current_world.terrain_pallette
    new_mintilex = @universe.current_world.topo_map.x_offset_for_world(@px - x_ext)
    new_maxtilex = @universe.current_world.topo_map.x_offset_for_world(@px + x_ext)
    new_mintiley = @universe.current_world.topo_map.y_offset_for_world(@py - y_ext)
    new_maxtiley = @universe.current_world.topo_map.y_offset_for_world(@py + y_ext)

    @px -= dx if clamp_to_tile_restrictions_on_x(tp, new_mintilex, new_mintiley, new_maxtilex, new_maxtiley)
    @py -= dy if clamp_to_tile_restrictions_on_y(tp, new_mintilex, new_mintiley, new_maxtilex, new_maxtiley)

    update_tile_coords

    # @rect.center = [@px, @py]
  end


end
# A class representing the player's ship moving in "space".

class AnimatedSpriteHelper
  attr_reader :image, :rect, :px, :py

  def initialize(filename, px, py, avatar_x_dim, avatar_y_dim)
    @all_char_postures = Surface.load(filename)
    @all_char_postures.colorkey = @all_char_postures.get_at(0,0)
    @all_char_postures.alpha = 255

    @px = px
    @py = py #XXX this might be a bug to use these, they should come from the coord helper?
    @avatar_x_dim = avatar_x_dim
    @avatar_y_dim = avatar_y_dim


    @image = Surface.new([@avatar_x_dim,@avatar_y_dim])
    @image.fill(@all_char_postures.colorkey)
    @image.colorkey = @all_char_postures.colorkey
    @image.alpha = 255
    @all_char_postures.blit(@image, [0,0], Rect.new(0,0,@avatar_x_dim,@avatar_y_dim))

    @rect = @image.make_rect
    @rect.center = [px, py]


  end


  def set_frame(last_dir=0)
    @last_direction_offset = last_dir
  end

  def replace_avatar(animation_frame)
    @image.fill(@all_char_postures.colorkey)
    @all_char_postures.blit(@image, [0,0], Rect.new(animation_frame * @avatar_x_dim, @last_direction_offset,@avatar_x_dim, @avatar_y_dim))
  end


end

class Ship
  include Sprites::Sprite
  include EventHandler::HasEventHandler
  
  attr_reader :inventory, :universe

  def image
    @animated_sprite_helper.image
  end
  def rect
    @animated_sprite_helper.rect
  end

  def add_inventory(qty, item)
    @inventory[item] += qty
  end

  def px
    @coordinate_helper.px
  end
  def py
    @coordinate_helper.py
  end

  def initialize( px, py,  universe)
    @universe = universe
    @hero_x_dim = 48
    @hero_y_dim = 64
    @interaction_helper = InteractionHelper.new(self, @universe)
    @inventory = Hash.new(0)
    @keys = KeyHolder.new
    @coordinate_helper = CoordinateHelper.new(px, py, @keys, @universe, @hero_x_dim, @hero_y_dim)
    @animation_helper = AnimationHelper.new(@keys)
    @coordinate_helper.update_tile_coords
    @animated_sprite_helper = AnimatedSpriteHelper.new("Charactern8.png", px, py, @hero_x_dim, @hero_y_dim)
    @animated_sprite_helper.set_frame(0)

    make_magic_hooks(
      KeyPressed => :key_pressed,
      KeyReleased => :key_released,
      ClockTicked => :update
    )
  end


  def interact_with_facing
    @interaction_helper.interact_with_facing( @coordinate_helper.px , @coordinate_helper.py)
  end

  private




  # Add it to the list of keys being pressed.
  def key_pressed( event )
    newkey = event.key
    if [:down, :left,:up, :right].include?(newkey)
      @interaction_helper.facing = newkey
    end
    
    if event.key == :down
      @animated_sprite_helper.set_frame(0)
    elsif event.key == :left
      @animated_sprite_helper.set_frame(@hero_y_dim)
    elsif event.key == :right
      @animated_sprite_helper.set_frame(2 * @hero_y_dim)
    elsif event.key == :up
      @animated_sprite_helper.set_frame(3 * @hero_y_dim)
    end
    @animated_sprite_helper.replace_avatar(@animation_helper.current_frame)

    @keys.add_key(event.key)
  end


  # Remove it from the list of keys being pressed.
  def key_released( event )
    @keys.delete_key(event.key)
    
  end

  # Update the ship state. Called once per frame.
  def update( event )
    dt = event.seconds # Time since last update
    @animation_helper.update_animation(dt) { |frame| @animated_sprite_helper.replace_avatar(frame) }
    @coordinate_helper.update_accel
    @coordinate_helper.update_vel( dt )
    @coordinate_helper.update_pos( dt )
  end






  def x_ext
    @hero_x_dim/2
  end
  def y_ext
    @hero_y_dim/2
  end


end


@@OPEN_TREASURE = 'O'

class Treasure
  attr_accessor :name
  def initialize(name)
    @name = name
  end

  def activate(player, worldstate, tilex, tiley)
    worldstate.interaction_map.update(tilex, tiley, @@OPEN_TREASURE)
    #XXX this is not graceful, don't have to reblit the whole thing

    worldstate.topo_map.update(tilex, tiley, @@OPEN_TREASURE)
    worldstate.topo_map.blit_to(worldstate.topo_pallette, worldstate.background_surface)
    puts "also, give it to the player"
    player.add_inventory(1, @name)
  end
end

class OpenTreasure < Treasure
  def activate( player, worldstate, tilex, tiley)
    puts "Nothing to do, already opened"
  end
end

class WarpPoint
  attr_accessor :destination
  def initialize(dest_index)
    @destination = dest_index
  end

  def activate(player, worldstate, tilex, tiley)
    uni = player.universe
    
    puts "warp from  #{worldstate} to #{uni.world_by_index(@destination)}"
    uni.set_current_world_by_index(@destination)
  end
end

class Monster
  @@MONSTER_X = 32
  @@MONSTER_Y = 32

  include Sprites::Sprite
  include EventHandler::HasEventHandler
  def px
    @animated_sprite_helper.px
  end
  def py
    @animated_sprite_helper.py
  end
  def initialize(filename, px, py, npc_x = @@MONSTER_X, npc_y = @@MONSTER_Y)
    super()
    @npc_x = npc_x
    @npc_y = npc_y
    @animated_sprite_helper = AnimatedSpriteHelper.new(filename, px, py, @npc_x, @npc_y)
    @animated_sprite_helper.set_frame(0)
    @keys = AlwaysDownMonsterKeyHolder.new
    @animation_helper = AnimationHelper.new(@keys, 3)
    make_magic_hooks(
      ClockTicked => :update
    )
  end

  def draw(surface,x,y,sx,sy)
    tx = @animated_sprite_helper.px - x + sx/2
    ty = @animated_sprite_helper.py - y + sy/2
    @animated_sprite_helper.image.blit surface, [tx,ty,96,128]
  end

  def update(event)
    dt = event.seconds # Time since last update
    @animation_helper.update_animation(dt) { |frame| @animated_sprite_helper.replace_avatar(frame) }
    
  end

  def distance_to(x,y)
    [(px - x).abs, (py - y).abs]
  end

  def nearby?(x,y, distx, disty)
    dist = distance_to(x,y)
    (dist[0] < distx) and (dist[1] < disty)
  end

  def interact(universe, player)
    puts "start a fight with #{self}"
  end
end


# The Game class helps organize thing. It takes events
# from the queue and handles them, sometimes performing
# its own action (e.g. Escape key = quit), but also
# passing the events to the pandas to handle.
#

class DialogLayer
  @@LAYER_INSET = 25
  @@TEXT_INSET = 10
  attr_accessor :visible, :text
  include FontLoader #TODO unify resource loading

  def initialize(screen)
    @screen = screen
    @visible = false
    @layer = Surface.new([(@screen.w/2) - @@LAYER_INSET, (@screen.h/2) - @@LAYER_INSET])
    @layer.fill(:red)
    @layer.alpha = 192
    @font = load_font("FreeSans.ttf")
    @text = "UNSET"
  end

  def toggle_visibility
    @visible = !@visible
  end

  def draw
    text_surface = @font.render @text.to_s, true, [16,222,16]
    text_surface.blit @layer, [@@TEXT_INSET,@@TEXT_INSET]
    @layer.blit(@screen, [@@LAYER_INSET,@@LAYER_INSET])
  end

  def displayed
    #TODO other logic like next page, gifts, etc goes here
    @visible = false
    puts "dialog done"
  end
  
end

class TalkingNPC < Monster
  def initialize(filename, px, py, npc_x, npc_y, text)
    super(filename, px, py, npc_x, npc_y)
    @text = text
  end

  def interact(universe, player)
    puts "display dialog '#{@text}' from #{self}"
    universe.dialog_layer.visible = true
    universe.dialog_layer.text = @text
  end

end

class Game
  include EventHandler::HasEventHandler

  def initialize()
    make_screen
    make_clock
    make_queue
    make_event_hooks
    
    make_world1
    make_world2
    make_dialog_layer
    make_universe
    make_ship
    make_hud

  end



  def make_hud
    @hud = Hud.new :screen => @screen, :player => @ship, :topomap => @topomap
  end
  def make_world1

    bg_data = ['M','M','M','M','M','M','M','M',
               'M','G','G','G','G','G','G','M',
               'M','G','T','G','G','G','G','M',
               'M','G','G','G','G','G','G','M',
               'M','G','G','G','G','G','W','M',
               'M','M','M','M','M','M','M','M'
    ]
    terrain_data = [ '.','.','.','.','.','.','.','.',
                      '.','e','e','e','e','e','e','.',
                      '.','e','T','e','e','e','e','.',
                      '.','e','e','e','e','e','e','.',
                      '.','e','e','e','e','e','e','.',
                      '.','.','.','.','.','.','.','.'
    ]
    interaction_data = [ '.','.','.','.','.','.','.','.',
                         '.','.','.','.','.','.','.','.',
                         '.','.','T','.','.','.','.','.',
                         '.','.','.','.','.','.','.','.',
                         '.','.','.','.','.','.','w','.',
                         '.','.','.','.','.','.','.','.'
    ]

    terrainmap = TopoMap.new(8,6, @@BGX, @@BGY, terrain_data)
    topomap = TopoMap.new(8,6, @@BGX,@@BGY, bg_data)
    interactmap = TopoMap.new(8,6, @@BGX,@@BGY, interaction_data)

    bgsurface = Surface.new([@@BGX,@@BGY])
    topomap.blit_to(pallette, bgsurface)

    npcs = [TalkingNPC.new("gogo-npc.png", 600, 200,48,64, "i am an npc."), Monster.new("monster.png", 400,660)]
    npcs.each {|npc|
      make_magic_hooks_for( npc, { YesTrigger.new() => :handle } )
    }

    @worldstate = WorldState.new(topomap, pallette, terrainmap, terrain_pallette, interactmap, interaction_pallette, npcs, bgsurface)
  end
  def make_world2

    bg_data = ['M','M','M','G','G','G','M','M',
               'M','G','G','T','T','T','G','M',
               'M','G','G','G','G','G','G','w',
               'M','G','G','G','G','G','G','w',
               'M','G','G','G','G','G','W','w',
               'M','M','M','M','w','w','w','w'
    ]
    terrain_data = [  '.','.','.','e','e','e','.','.',
                      '.','e','e','T','T','T','e','.',
                      '.','e','e','e','e','e','e','.',
                      '.','e','e','e','e','e','e','.',
                      '.','e','e','e','e','e','e','.',
                      '.','.','.','.','.','.','.','.'
    ]
    interaction_data = [ '.','.','.','.','.','.','.','.',
                         '.','.','.','1','2','3','.','.',
                         '.','.','.','.','.','.','.','.',
                         '.','.','.','.','.','.','.','.',
                         '.','.','.','.','.','.','W','.',
                         '.','.','.','.','.','.','.','.'
    ]
    
    terrainmap = TopoMap.new(8,6, @@BGX, @@BGY, terrain_data)
    topomap = TopoMap.new(8,6, @@BGX,@@BGY, bg_data)
    interactmap = TopoMap.new(8,6, @@BGX,@@BGY, interaction_data)
 
    bgsurface = Surface.new([@@BGX,@@BGY])
    topomap.blit_to(pallette, bgsurface)
    npcs = []
    
    @worldstate2 = WorldState.new(topomap, pallette, terrainmap, terrain_pallette, interactmap, interaction_pallette, npcs, bgsurface)
  end

  # The "main loop". Repeat the #step method
  # over and over and over until the user quits.
  def go
    catch(:quit) do
      loop do
        step
      end
    end
  end


  private


  # Create a new Clock to manage the game framerate
  # so it doesn't use 100% of the CPU
  def make_clock
    @clock = Clock.new()
    @clock.target_framerate = 50
    @clock.calibrate
    @clock.enable_tick_events
  end


  # Set up the event hooks to perform actions in
  # response to certain events.
  def make_event_hooks
    hooks = {
      :escape => :quit,
      :q => :quit,
      QuitRequested => :quit,
      :c => :capture_ss,
      :i => :interact_with_facing,
      :d => :toggle_dialog_layer
    }

    make_magic_hooks( hooks )
  end

  def toggle_dialog_layer
    @dialog_layer.toggle_visibility
  end
  def interact_with_facing(event)
    @ship.interact_with_facing
  end

  def capture_ss(event)
    #TODO this does not work, find a different way to dump screen data
#    def @screen.monkeypatch
#      filename = "screenshot.bmp"
#      result = SDL.SaveBMP_RW( @struct, filename )
#      if(result != 0)
#       raise( Rubygame::SDLError, "Couldn't save surface to file %s: %s"%\
#             [filename, SDL.GetError()] )
#      end
#      nil
#    end
    
    #@screen.savebmp("screenshot.bmp")

    SDL.SaveBMP_RW("screenshot.bmp",@screen, 0)
  end


  # Create an EventQueue to take events from the keyboard, etc.
  # The events are taken from the queue and passed to objects
  # as part of the main loop.
  def make_queue
    # Create EventQueue with new-style events (added in Rubygame 2.4)
    @queue = EventQueue.new()
    @queue.enable_new_style_events

    # Don't care about mouse movement, so let's ignore it.
    @queue.ignore = [MouseMoved]
  end


  # Create the Rubygame window.
  def make_screen
    @screen = Screen.open( [640, 480] )
    @screen.title = "Square! In! Space!"
  end

  def make_dialog_layer
    @dialog_layer = DialogLayer.new(@screen)
  end
  def make_universe
    @universe = Universe.new([@worldstate, @worldstate2], @dialog_layer)
  end
  # Create the player ship in the middle of the screen
  def make_ship
    #@ship = Ship.new( @screen.w/2, @screen.h/2, @topomap, pallette, @terrainmap, terrain_pallette, @interactmap, interaction_pallette, @bgsurface )
    @ship = Ship.new( @screen.w/2, @screen.h/2, @universe )

    # Make event hook to pass all events to @ship#handle().
    make_magic_hooks_for( @ship, { YesTrigger.new() => :handle } )
  end


  # Quit the game
  def quit
    puts "Quitting!"
    throw :quit
  end


  # Do everything needed for one frame.
  def step
    # Clear the screen.
    @screen.fill( :black )
#    puts "ship is at #{@ship.px}, #{@ship.py}"
#    puts "ship rect is #{@ship.rect}"
#    puts "bg is #{@bgimage.size}"
    
    
    @sx = 640
    @sy = 480
    @universe.current_world.background_surface.blit(@screen, [0,0], [ @ship.px - (@sx/2), @ship.py - (@sy/2), @sx, @sy])

    @universe.current_world.npcs.each {|npc|

      npc.draw(@screen, @ship.px, @ship.py, @sx, @sy) if npc.nearby?(@ship.px, @ship.py, @sx/2, @sy/2)

    }
    
    #@topomap.blit_with_pallette(pallette, @screen, @ship.px, @ship.py)
#    puts "topomap should be in (#{@topomap.x_offset_for_world(@ship.px)},#{@topomap.y_offset_for_world(@ship.py)})"


    # Fetch input events, etc. from SDL, and add them to the queue.
    @queue.fetch_sdl_events

    # Tick the clock and add the TickEvent to the queue.
    tick = @clock.tick
    @queue << tick
    @hud.update :time => "Framerate: #{1.0/tick.seconds}"
    # Process all the events on the queue.
    @queue.each do |event|
      handle( event )
    end

    # Draw the ship in its new position.

    @ship.draw(@screen)
    @hud.draw
    if @universe.dialog_layer.visible
      @universe.dialog_layer.draw
    end
    # Refresh the screen.
    @screen.update()
  end

  def tile(color)
    s = Surface.new([160,160])
    s.fill(color)
    s
  end
  def interaction_pallette
    pal = Hash.new(false)
    pal['O'] = OpenTreasure.new("O")
    pal['T'] = Treasure.new("T")
    pal['1'] = Treasure.new("1")
    pal['2'] = Treasure.new("2")
    pal['3'] = Treasure.new("3")

    pal['w'] = WarpPoint.new(1)
    pal['W'] = WarpPoint.new(0)

    pal
  end

  def terrain_pallette
    pal = Hash.new(true)
    pal['T'] = false
    pal['.'] = false
    pal['e'] = true
    pal
  end
  

  def pallette
    pal = Hash.new(tile(:blue))
    pal['a'] = tile(:yellow)
    pal['b'] = tile(:yellow)
    pal['c'] = tile(:red)
    pal['d'] = tile(:red)
    pal['e'] = tile(:green)
    pal['f'] = tile(:green)
    pal['g'] = tile(:white)
    pal['h'] = tile(:white)
    pal['i'] = tile(:brown)
    pal['j'] = tile(:brown)
    pal['k'] = tile(:magenta)
    pal['l'] = tile(:magenta)
    
    pal['O'] = Surface.load("open-treasure-on-grass-bg-160.png")
    pal['T'] = Surface.load("treasure-on-grass-bg-160.png")
    pal['w'] = Surface.load("water-bg-160.png")
    pal['W'] = Surface.load("town-on-grass-bg-160.png")
    pal['M'] = Surface.load("mountain-bg-160.png")
    pal['G'] = Surface.load("grass-bg-160.png")
    pal
  end

end


# Start the main game loop. It will repeat forever
# until the user quits the game!
Game.new.go


# Make sure everything is cleaned up properly.
Rubygame.quit()