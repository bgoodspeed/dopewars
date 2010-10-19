

class TopoMapFactory
  extend ResourceLoader


  def self.build_map(filename,bgx, bgy)
    lines = self.load_mapfile(filename)
    data = []
    lines.each {|line| data += line.strip.split(//)}

    chrs = lines[0].strip.split(//)
    x = chrs.size
    y = lines.size

    TopoMap.new(x,y,bgx, bgy, data)
  end
end
