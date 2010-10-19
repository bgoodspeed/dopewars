class TextRenderingConfig
  attr_reader :xc,:xf,:yc,:yf
  def initialize(xc,xf,yc,yf)
    @xc = xc
    @xf = xf
    @yc = yc
    @yf = yf
  end

  def cursor_offsets_at(position, game, menu_action)
    [@xc + @xf * position, @yc + @yf * position]
  end
end