# To change this template, choose Tools | Templates
# and open the template in the editor.

#XXX this based on the rubygame surface which is to say an SDL 2d surface, formalize these needs/test them


class SurfaceFacade < Rubygame::Surface
#  extend Forwardable
#  include Rubygame
#
#  def_delegators :@surface, :fill, :colorkey=, :alpha=
#  def initialize(dims)
#    @surface = make_real_surface(dims)
#  end
#
# private
#  def make_real_surface(dims)
#    Surface.new(dims)
#  end

  def self.load(filename)
    
    surface = Rubygame::Surface.load(filename)
    facade = SurfaceFacade.new([surface.w, surface.h])

    surface.blit(facade, [0,0])
    facade
  end

end
