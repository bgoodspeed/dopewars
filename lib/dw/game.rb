#!/usr/bin/env ruby

# This is just a blank window that I use as the starting point for all my games

require 'rubygems'
require 'rubygame'

require 'font_loader'
require 'hud'




class Game

  include Rubygame
  include Rubygame::Events
  include EventHandler::HasEventHandler

	def initialize
		@screen = Rubygame::Screen.new [640,480], 0, [Rubygame::HWSURFACE, Rubygame::DOUBLEBUF]
		@screen.title = "Generic Game!"

		@queue = Rubygame::EventQueue.new
		@clock = Rubygame::Clock.new
		@clock.target_framerate = 30
    @hud = Hud.new :screen => @screen

    make_event_hooks
	end
 def make_event_hooks
    hooks = {
      :escape => :quit,
      :q => :quit,
      QuitRequested => :quit
    }

    make_magic_hooks( hooks )
  end
  def quit
    puts "Quitting!"
    throw :quit
  end
 	def run
    catch(:quit) do
      loop do
  			update
    		draw
      	@clock.tick
      end
    end

	end

	def update
		@queue.each do |ev|
      handle(ev)
			case ev
      when Rubygame::QuitEvent
        Rubygame.quit
        exit
			end
      
		end
    @hud.update :time => @time

	end

	def draw
    @screen.fill :black
    @hud.draw
    @screen.update
	end
end

game = Game.new
game.run