
class SurfaceBackedPallette < Pallette

  include Rubygame

  attr_reader :tile_x, :tile_y
  def initialize(filename, x, y, pal=nil)
    super(nil,pal)
    @surface = Surface.load(filename)
    @tile_x = x
    @tile_y = y
  end
  def offsets(key)
    @pal[key]
  end


  def [](key)
    entry = @pal[key]
    offset_x = entry.offsets[0]
    offset_y = entry.offsets[1]
    s = Surface.new([@tile_x,@tile_y])
    @surface.blit(s,[0,0], [offset_x * @tile_x, offset_y * @tile_y, @tile_x, @tile_y]  )
    SBPResult.new(s, entry.actionable, self)
  end
end

