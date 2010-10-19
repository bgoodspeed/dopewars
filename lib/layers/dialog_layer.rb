
class DialogLayer < AbstractLayer
  attr_accessor :visible, :text

  def initialize(screen, game)
    super(screen, screen.w/2 - @@LAYER_INSET, screen.h/2 - @@LAYER_INSET)
    @layer.fill(:red)
    @layer.alpha = 192
    @text = "UNSET"
  end

  def toggle_visibility
    @visible = !@visible
  end

  def draw
    text_surface = @font.render @text.to_s, true, [16,222,16]
    text_surface.blit @layer, [@@TEXT_INSET,@@TEXT_INSET]
    @layer.blit(@screen, [@@LAYER_INSET,@@LAYER_INSET])
  end

  def displayed
    #TODO other logic like next page, gifts, etc goes here
    @active = false
  end
end