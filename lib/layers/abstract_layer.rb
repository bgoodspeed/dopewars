
class AbstractLayer
  include ResourceLoader
  attr_accessor :active, :layer

  def initialize(screen, layer_width, layer_height, surface_factory=SurfaceFactory.new)
    @screen = screen
    @active = false
    @layer = surface_factory.make_surface([layer_width, layer_height])
    @font = load_font("FreeSans.ttf")
    @text_rendering_helper = TextRenderingHelper.new(@layer, @font)
  end

  def toggle_activity
    @active = !@active
  end

  alias_method :active?, :active
  alias_method :visible, :active
  alias_method :toggle_visibility, :toggle_activity
end