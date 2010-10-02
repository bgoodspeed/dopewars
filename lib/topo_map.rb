# To change this template, choose Tools | Templates
# and open the template in the editor.

class TopoMap
  def initialize(x,y, world_x, world_y, data)
    @x = x
    @y = y
    @world_x = world_x
    @world_y = world_y
    @data = data
    @xsize = @world_x/@x
    @ysize = @world_y/@y

  end

  def viewport_data_for(xoff,yoff, xdim=1, ydim=1)
    rv = []
    0.upto(ydim - 1) do |yi|
      0.upto(xdim - 1) do |xi|
        rv << data_at(xi + xoff, yi + yoff)
      end
    end
    rv
  end

  def update(tx,ty, new_value)
    @data[ty * @x + tx] = new_value
  end

  def left_side(tilex)
    @xsize * tilex
  end
  def right_side(tilex)
    @xsize * (tilex + 1)
  end
  def top_side(tilex)
    @ysize * tilex
  end
  def bottom_side(tilex)
    @ysize * (tilex + 1)
  end

  def data_at(xoff,yoff)
    @data[yoff * @x + xoff]
  end

  def x_offset_for_world(wx)
    (wx / @xsize).to_i
  end
  def y_offset_for_world(wy)
    (wy / @ysize).to_i
  end
  def blit_to(palette, target)
    0.upto(@y) do |yi|
      0.upto(@x) do |xi|
        palette[data_at(xi,yi)].blit(target, [xi*@xsize, yi*@ysize])
      end
    end

  end

  def blit_with_pallette(palette, target, wmx, wmy)
    vdata = viewport_data_for(x_offset_for_world(wmx), y_offset_for_world(wmy), 4,3)

    0.upto(3) do |yi|
      0.upto(4) do |xi|
        palette[vdata[yi*@x+xi]].blit(target, [xi*160, yi*160])
      end
    end
    
  end
end
