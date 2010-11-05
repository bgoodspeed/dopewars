# To change this template, choose Tools | Templates
# and open the template in the editor.

class PositionedTileCoordinate
  attr_accessor :position, :dimension
  def initialize(position_coords, dimension_coords)
    @position = position_coords
    @dimension = dimension_coords
    
  end
end
