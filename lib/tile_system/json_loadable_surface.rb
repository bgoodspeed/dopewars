
class JsonLoadableSurface
  include Rubygame
  include ResourceLoader
  extend Forwardable
  def_delegators :@surface, :blit

  def initialize(filename, blocking)
    @filename = filename
    @blocking = blocking
    @surface = load_surface(filename)
  end

  def is_blocking?
    @blocking
  end
end
