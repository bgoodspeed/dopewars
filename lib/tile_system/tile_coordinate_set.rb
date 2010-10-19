class TileCoordinateSet
  attr_reader :minx, :maxx, :miny, :maxy
  def initialize(minx, maxx, miny, maxy)
    @minx = minx
    @maxx = maxx
    @miny = miny
    @maxy = maxy
  end
end