#!/bin/env ruby

# One way of making an object start and stop moving gradually:
# make user input affect acceleration, not velocity.

require 'rubygems'

require 'perftools'
require 'ruby-prof'

require 'rubygame'
require 'json'
require 'forwardable'

require 'lib/game_settings'
require 'lib/game_requirements'

g = Game.new

def the_profiled_code(g, iters=100)
  iters.times { g.step }
end


PerfTools::CpuProfiler.start("perftools.profile") do
  the_profiled_code(g)
end

require 'ruby-prof'

# Profile the code
result = RubyProf.profile do
  the_profiled_code(g)
end


profile_printers = {RubyProf::GraphPrinter.new(result) => "rubyprof.graph.profile",
                    RubyProf::FlatPrinter.new(result) => "rubyprof.flat.profile",
                    RubyProf::CallTreePrinter.new(result) => "rubyprof.calltree.profile"
                    }

profile_printers.each {|printer, path| printer.print(File.new(path, "w"), 0)}

Rubygame.quit()
