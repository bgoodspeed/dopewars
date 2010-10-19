
class JsonLoadableSurface
  include Rubygame
  extend Forwardable
  def_delegators :@surface, :blit

  def initialize(filename, blocking)
    @filename = filename
    @blocking = blocking
    @surface = Surface.load(filename)
  end

  def is_blocking?
    @blocking
  end
end
