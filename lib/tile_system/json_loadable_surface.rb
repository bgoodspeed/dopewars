
class JsonLoadableSurface
  extend Forwardable
  def_delegators :@surface, :blit

  def initialize(filename, blocking, surface_factory=SurfaceFactory.new)
    @filename = filename
    @blocking = blocking
    @surface = surface_factory.load_surface(filename)
  end

  def is_blocking?
    @blocking
  end
end
