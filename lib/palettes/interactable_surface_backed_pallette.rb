
class InteractableSurfaceBackedPallette < SurfaceBackedPallette

  def [](key)
    entry = @pal[key]
    return nil if entry.nil?
    s = @surface_factory.make_surface([@tile_x,@tile_y])
    @surface.blit(s, [0,0], [entry.offsets[0] * @tile_x, entry.offsets[1] * @tile_y, @tile_x, @tile_y] )
    ISBPResult.new(s, entry.actionable, self)
  end
end
