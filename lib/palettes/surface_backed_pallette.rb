
class SurfaceBackedPallette < Pallette

  attr_reader :tile_x, :tile_y
  def initialize(filename, x, y, pal=nil, surface_factory=SurfaceFactory.new)
    super(nil,pal)
    @surface_factory = surface_factory
    @surface = @surface_factory.load_surface(filename)
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
    s = @surface_factory.make_surface([@tile_x,@tile_y])
    @surface.blit(s,[0,0], [offset_x * @tile_x, offset_y * @tile_y, @tile_x, @tile_y]  )
    SBPResult.new(s, entry.actionable, self)
  end
end

