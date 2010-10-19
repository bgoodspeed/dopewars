#!/bin/env ruby

# One way of making an object start and stop moving gradually:
# make user input affect acceleration, not velocity.


require "rubygame"
require 'position'
require 'font_loader'
require 'ship'
require 'hud'

# Include these modules so we can type "Surface" instead of
# "Rubygame::Surface", etc. Purely for convenience/readability.

include Rubygame
include Rubygame::Events
include Rubygame::EventActions
include Rubygame::EventTriggers


class Collision
  attr_accessor :hittee, :hitter
  include EventHandler::HasEventHandler
  
  def initialize(static, dynamic)
    @hittee = static
    @hitter = dynamic
  end

  def foo(event)
    raise "victoly"
  end
end

class Location
  @@THRESHOLD = 5
  
  include Sprites::Sprite
  include EventHandler::HasEventHandler
  def initialize( px, py )
    @px, @py = px, py
    @image = Surface.new([10,10])
    color = :red
    color = :blue if ((px % 20) == 0)
    @image.fill(color)
    @rect = @image.make_rect
    @rect.center = [@px, @py]
    make_magic_hooks(  ClockTicked => :update

    )
  end

  def intersects_with(x, y)
    return false if (@px - x).abs > @@THRESHOLD
    return (@py - y).abs <= @@THRESHOLD
  end

  def process_collision(event)
    puts "collided: #{event.hittee} with #{event.hitter}"
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
    make_ship
    make_hud
    make_locations
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
      QuitRequested => :quit
    }

    make_magic_hooks( hooks )
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

  def make_hud
     @hud = Hud.new :screen => @screen
  end

  # Create the player ship in the middle of the screen
  def make_ship
    @ship = Ship.new( @screen.w/2, @screen.h/2 )

    # Make event hook to pass all events to @ship#handle().
    make_magic_hooks_for( @ship, { YesTrigger.new() => :handle } )
  end


  def make_locations
    #make_magic_hooks( Collision => :process_collision )

    @locations = 1.upto(10).collect do |i|  
      loca = Location.new(10 * i, 10 * i)
      make_magic_hooks_for(loca, { Collision => :process_collision })
      loca
    end

  end

  
  # Quit the game
  def quit
    puts "Quitting!"
    throw :quit
  end

  def collides_with(ship, locations)
    @locations.select do |location|
      location.intersects_with(ship.position_x, ship.position_y)
    end.collect do |location|
      puts "collision"
      Collision.new(location, ship)
    end
  end

  # Do everything needed for one frame.
  def step
    # Clear the screen.
    @screen.fill( :black )

    # Fetch input events, etc. from SDL, and add them to the queue.
    @queue.fetch_sdl_events

    collisions = collides_with(@ship, @locations)
      
    collisions.each do |collision|
      @queue << collision
    end



    # Tick the clock and add the TickEvent to the queue.
    @queue << @clock.tick

    # Process all the events on the queue.
    @queue.each do |event|
      handle( event )
    end

    @locations.each do |loca|
      loca.draw(@screen)
    end
    @hud.update :time => @time
    # Draw the ship in its new position.
    @ship.draw( @screen )
    @hud.draw
    # Refresh the screen.
    @screen.update()
  end

end


# Start the main game loop. It will repeat forever
# until the user quits the game!
Game.new.go


# Make sure everything is cleaned up properly.
Rubygame.quit()