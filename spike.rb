#!/bin/env ruby

# One way of making an object start and stop moving gradually:
# make user input affect acceleration, not velocity.

require 'rubygems'

require 'rubygame'
require 'json'
require 'forwardable'

require 'lib/game_settings'
require 'lib/game_requirements'

g = Game.new

puts "maybe stick the intro screen here"

g.go

Rubygame.quit()