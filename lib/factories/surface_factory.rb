# To change this template, choose Tools | Templates
# and open the template in the editor.

class SurfaceFactory
  include ResourceLoader

  def make_surface(dims)
    SurfaceFacade.new(dims)
  end

  
end
