
class AbstractLayer
  include FontLoader #TODO unify resource loading
  attr_accessor :active

  def initialize(screen, layer_width, layer_height)
    @screen = screen
    @active = false
    @layer = Surface.new([layer_width, layer_height])
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