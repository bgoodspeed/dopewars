# To change this template, choose Tools | Templates
# and open the template in the editor.

class TopoMap

  attr_reader :world_x, :world_y
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
    0.upto(@y-1) do |yi|
      0.upto(@x-1) do |xi|
        datum = palette[data_at(xi,yi)]
        datum.blit(target, [xi*@xsize, yi*@ysize])
      end
    end
  end

  def blit_foreground(palette, screen, px, py)
    xoff = x_offset_for_world(px)
    yoff = x_offset_for_world(py)
    horizontal_tile_offset = ((screen.w/2)/@xsize).ceil
    vertical_tile_offset = ((screen.h/2)/@ysize).ceil
    startx = [0,xoff - horizontal_tile_offset].max
    endx = [@x, xoff + horizontal_tile_offset].min

    starty = [0,yoff - vertical_tile_offset].max
    endy = [@y, yoff + vertical_tile_offset].min

    starty.upto(endy) do |yi|
      startx.upto(endx) do |xi|

        datum = palette[data_at(xi,yi)]
        unless datum.nil?

          datum.blit(screen, px,py, xi, yi)
        end
      end
    end
    
  end

  include JsonHelper

  def json_params
    [  @x, @y, @world_x, @world_y, @data]
  end

end
