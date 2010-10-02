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


# A class representing the player's ship moving in "space".
class Ship
  include Sprites::Sprite
  include EventHandler::HasEventHandler

  attr_reader :px, :py, :inventory

  def add_inventory(qty, item)
    @inventory[item] += qty
  end

  def initialize( px, py, topomap=nil, topopal = nil, terrainmap = nil, tp=nil, interactmap=nil, intpallet=nil, bgsurface=nil)
    @bgsurface = bgsurface
    @terrain_pallette = tp
    @terrainmap = terrainmap
    @topomap = topomap
    @topo_pallette = topopal
    @interactionmap = interactmap
    @interaction_pallette = intpallet
    @px, @py = px, py # Current Position
    @vx, @vy = 0, 0 # Current Velocity
    @ax, @ay = 0, 0 # Current Acceleration
    @hero_x_dim = 48
    @hero_y_dim = 64
    @facing = :down
    @inventory = Hash.new(0)
    update_tile_coords
    @max_speed = 400.0 # Max speed on an axis
    @accel = 1200.0 # Max Acceleration on an axis
    @slowdown = 800.0 # Deceleration when not accelerating
    @keys = [] # Keys being pressed
    @animation_counter = 0
    @animation_frame = 0

    # The ship's appearance. A white square for demonstration.
    #@image = Surface.new([20,20])
    #@image.fill(:white)
    @all_char_postures = Surface.load("Charactern8.png")
    @all_char_postures.colorkey = @all_char_postures.get_at(0,0)
    #@all_char_postures.colorkey = [128,128,128]
    @all_char_postures.alpha = 255
    
    @image = Surface.new([@hero_x_dim,@hero_y_dim])
    @image.fill(@all_char_postures.colorkey)
    @image.colorkey = @all_char_postures.colorkey
    @image.alpha = 255
    puts "screen color key #{@image.colorkey}"
    
    @all_char_postures.blit(@image, [0,0], Rect.new(0,0,@hero_x_dim,@hero_y_dim))
    set_frame(0)

    @rect = @image.make_rect
    @rect.center = [@px, @py]

    # Create event hooks in the easiest way.
    make_magic_hooks(

      # Send keyboard events to #key_pressed() or #key_released().
      KeyPressed => :key_pressed,
      KeyReleased => :key_released,

      # Send ClockTicked events to #update()
      ClockTicked => :update

    )
  end

  @@INTERACTION_DISTANCE_THRESHOLD = 80 #XXX tweak this, currently set to 1/2 a tile

  def interact_with_facing


    puts "you are facing #{@facing}"
    tilex = @topomap.x_offset_for_world(@px)
    tiley = @topomap.y_offset_for_world(@py)
    this_tile_interacts = @interaction_pallette[@interactionmap.data_at(tilex,tiley)]
    facing_tile_interacts = false
    
    if this_tile_interacts
      puts "you can interact with the current tile"
    end

    if @facing == :down
      facing_tilex = tilex
      facing_tiley = tiley + 1
      facing_tile_dist = (@interactionmap.top_side(tiley + 1) - @py).abs
    end
    if @facing == :up
      facing_tilex = tilex
      facing_tiley = tiley - 1
      facing_tile_dist = (@interactionmap.bottom_side(tiley - 1) - @py).abs
    end
    if @facing == :left
      facing_tilex = tilex - 1
      facing_tiley = tiley
      facing_tile_dist = (@interactionmap.right_side(tilex - 1) - @px).abs
    end
    if @facing == :right
      facing_tilex = tilex + 1
      facing_tiley = tiley
      facing_tile_dist = (@interactionmap.left_side(tilex + 1) - @px).abs
    end

    facing_tile_interacts = @interaction_pallette[@interactionmap.data_at(facing_tilex, facing_tiley)]
    facing_tile_close_enough = facing_tile_dist < @@INTERACTION_DISTANCE_THRESHOLD

    if facing_tile_close_enough and facing_tile_interacts
      puts "you can interact with the facing tile in the #{@facing} direction, it is at #{facing_tilex} #{facing_tiley}"
      facing_tile_interacts.activate(self, @interactionmap, facing_tilex, facing_tiley, @bgsurface, @topomap, @topo_pallette)
    end

    
  end

  private


  def set_frame(last_dir=0)
    @last_direction_offset = last_dir
  end

  def replace_avatar
    @image.fill(@all_char_postures.colorkey)
    @all_char_postures.blit(@image, [0,0], Rect.new(@animation_frame * @hero_x_dim, @last_direction_offset,@hero_x_dim, @hero_y_dim))
  end



  # Add it to the list of keys being pressed.
  def key_pressed( event )
    newkey = event.key
    if [:down, :left,:up, :right].include?(newkey)
      @facing = newkey
    end
    
    if event.key == :down
      set_frame(0)
    elsif event.key == :left
      set_frame(@hero_y_dim)
    elsif event.key == :right
      set_frame(2 * @hero_y_dim)
    elsif event.key == :up
      set_frame(3 * @hero_y_dim)
    end
    replace_avatar

    @keys += [event.key]
  end


  # Remove it from the list of keys being pressed.
  def key_released( event )
    @keys -= [event.key]
  end

  @@FRAME_SWITCH_THRESHOLD = 0.40
  @@ANIMATION_FRAMES = 4
  # Update the ship state. Called once per frame.
  def update( event )
    dt = event.seconds # Time since last update

    @animation_counter += dt
    if @animation_counter > @@FRAME_SWITCH_THRESHOLD
      @animation_counter = 0
      unless @keys.empty?
        @animation_frame = (@animation_frame + 1) % @@ANIMATION_FRAMES
        replace_avatar
      end
    end
    update_accel
    update_vel( dt )
    update_pos( dt )
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


  # Update the position based on the velocity and the time since last
  # update.
  def update_tile_coords
    @mintilex = @topomap.x_offset_for_world(@px - x_ext)
    @maxtilex = @topomap.x_offset_for_world(@px + x_ext)
    @mintiley = @topomap.y_offset_for_world(@py - y_ext)
    @maxtiley = @topomap.y_offset_for_world(@py + y_ext)
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
    @px = @@BGX - x_ext if maxx > @@BGX

    @py = y_ext if miny < 0
    @py = @@BGY - y_ext if maxy > @@BGY
  end

  def update_pos( dt )
    dx = @vx * dt
    dy = @vy * dt
    @px += dx
    @py += dy

    clamp_to_world_dimensions

    new_mintilex = @topomap.x_offset_for_world(@px - x_ext)
    new_maxtilex = @topomap.x_offset_for_world(@px + x_ext)
    new_mintiley = @topomap.y_offset_for_world(@py - y_ext)
    new_maxtiley = @topomap.y_offset_for_world(@py + y_ext)
    tp = @terrain_pallette

    undo_x = false
    undo_y = false

    if new_mintilex != @mintilex
      bottom_left = @terrainmap.data_at(new_mintilex, new_mintiley)
      top_left = @terrainmap.data_at(new_mintilex, new_maxtiley)
      unless tp[bottom_left] and tp[top_left]
        undo_x = true
      end
    end

    if new_maxtilex != @maxtilex
      bottom_right = @terrainmap.data_at(new_maxtilex, new_mintiley)
      top_right = @terrainmap.data_at(new_maxtilex, new_maxtiley)
      
      unless tp[bottom_right] and tp[top_right]
        undo_x = true
      end
    end

    if new_mintiley != @mintiley
      bottom_right = @terrainmap.data_at(new_maxtilex, new_mintiley)
      bottom_left = @terrainmap.data_at(new_mintilex, new_mintiley)

      unless tp[bottom_left] and tp[bottom_right]
        undo_y = true
      end
    end
    if new_maxtiley != @maxtiley

      top_right = @terrainmap.data_at(new_maxtilex, new_maxtiley)
      top_left = @terrainmap.data_at(new_mintilex, new_maxtiley)

      unless tp[top_left] and tp[top_right]
        undo_y = true
      end

    end

    @px -= dx if undo_x
    @py -= dy if undo_y

    update_tile_coords

    # @rect.center = [@px, @py]
  end

end


@@OPEN_TREASURE = 'O'

class Treasure
  attr_accessor :name
  def initialize(name)
    @name = name
  end

  def activate(player, interactionmap, tilex, tiley, bgsurface, topomap, pallette)
    interactionmap.update(tilex, tiley, @@OPEN_TREASURE)
    #XXX this is not graceful, don't have to reblit the whole thing

    topomap.update(tilex, tiley, @@OPEN_TREASURE)
    topomap.blit_to(pallette, bgsurface)
    puts "also, give it to the player"
    player.add_inventory(1, @name)
  end
end

class OpenTreasure < Treasure
  def activate(player, interactionmap, tilex, tiley, bgsurface, topomap, pallette)
    puts "Nothing to do, already opened"
  end
end

class WarpPoint
  attr_accessor :destination
  def initialize(dest)
    @destination = dest
  end

end




# The Game class helps organize thing. It takes events
# from the queue and handles them, sometimes performing
# its own action (e.g. Escape key = quit), but also
# passing the events to the pandas to handle.
#
class Game
  include EventHandler::HasEventHandler

  def initialize()
    make_screen
    make_clock
    make_queue
    make_event_hooks
    
    make_background
    make_ship
    make_hud

  end



  def make_hud
    @hud = Hud.new :screen => @screen, :player => @ship, :topomap => @topomap
  end
  def make_background

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
    @terrainmap = TopoMap.new(8,6, @@BGX, @@BGY, terrain_data)
    @topomap = TopoMap.new(8,6, @@BGX,@@BGY, bg_data)
    @interactmap = TopoMap.new(8,6, @@BGX,@@BGY, interaction_data)
    @bgimage = Surface.new([200,200])
    @bgimage.fill(:red)
    @bgimage2 = Surface.new([180,180])
    @bgimage2.fill(:green)


    @bgsurface = Surface.new([@@BGX,@@BGY])
    @topomap.blit_to(pallette, @bgsurface)


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
      :i => :interact_with_facing
    }

    make_magic_hooks( hooks )
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


  # Create the player ship in the middle of the screen
  def make_ship
    @ship = Ship.new( @screen.w/2, @screen.h/2, @topomap, pallette, @terrainmap, terrain_pallette, @interactmap, interaction_pallette, @bgsurface )

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
    
    @bgimage.blit(@screen, [0,0])
    @bgimage2.blit(@screen, [200,200])
    
    @sx = 640
    @sy = 480
    @bgsurface.blit(@screen, [0,0], [ @ship.px - (@sx/2), @ship.py - (@sy/2), @sx, @sy])
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
    pal['w'] = WarpPoint.new("Destination")
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