
class DialogLayer < AbstractLayer
  attr_accessor :visible, :text

  def initialize(screen, game)
    super(screen, screen.w/2 - GameSettings::LAYER_INSET, screen.h/2 - GameSettings::LAYER_INSET)
    @layer.fill(:red)
    @layer.alpha = 192
    @text = "UNSET"
  end

  def toggle_visibility
    @visible = !@visible
  end

  def draw
    text_surface = @font.render @text.to_s, true, [16,222,16]
    text_surface.blit @layer, [GameSettings::TEXT_INSET,GameSettings::TEXT_INSET]
    @layer.blit(@screen, [GameSettings::LAYER_INSET,GameSettings::LAYER_INSET])
  end

  def displayed
    #TODO other logic like next page, gifts, etc goes here
    @active = false
  end
end