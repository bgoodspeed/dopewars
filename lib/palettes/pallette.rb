
class Pallette
  def initialize(default_value, updated=nil)
    @default_value = default_value
    if updated.nil?
      @pal = Hash.new(default_value)
    else
      @pal = updated
    end

  end

  def []=(key,value)
    @pal[key] = value
  end

  def [](key)
    @pal[key]
  end

  def blit(target, xi, yi, datum, xsize, ysize)
    datum.blit(target, [xi*xsize, yi * ysize])
  end
end
