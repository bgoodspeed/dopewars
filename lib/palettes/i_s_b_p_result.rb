
class ISBPResult
  include ScreenOffsetHelper

  attr_reader :surface
  attr_accessor :actionable
  def initialize(sdl_surface, actionable, wrapped_surface)
    @surface=  sdl_surface
    @actionable = actionable
    @wrapped_surface = wrapped_surface
  end
  extend Forwardable
  def_delegators :@actionable, :activate
  def_delegators :@surface, :w,:h
  #  def activate(player, worldstate, tilex, tiley)
  #    @actionable.activate(player, worldstate, tilex, tiley)
  #  end

  def screen_position_relative_to(px,py,xi,yi,sextx,sexty)
    tx = @wrapped_surface.tile_x
    ty = @wrapped_surface.tile_y
    xoff = offset_from_screen(xi*tx, px, sextx)
    yoff = offset_from_screen(yi*ty, py, sexty)
    [xoff,yoff]
  end

  def blit(screen, px,py,xi, yi)
    @surface.blit(screen, screen_position_relative_to(px,py,xi,yi, screen.w/2, screen.h/2))
  end

  def blit_onto(screen, args)
    @surface.blit(screen, args)
  end
  def is_blocking?
    @actionable.is_blocking?
  end
end
