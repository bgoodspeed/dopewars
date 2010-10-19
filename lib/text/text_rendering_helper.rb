class TextRenderingHelper
  def initialize(layer, font)
    @layer = layer
    @font = font
  end
  def render_lines_to_layer(text_lines, conf)
    render_lines_to(@layer, text_lines, conf)
  end

  def render_lines_to(layer, text_lines, conf)
    text_lines.each_with_index do |text, index|
      text_surface = @font.render text.to_s, true, [16,222,16]
      text_surface.blit layer, [conf.xc + conf.xf * index,conf.yc + conf.yf * index]
    end
  end

end

