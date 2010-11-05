# To change this template, choose Tools | Templates
# and open the template in the editor.

class FontFacade
  extend Forwardable
  def_delegators :@real, :render
  
  def initialize(filename, depth)
    Rubygame::TTF.setup
    @real = Rubygame::TTF.new filename, depth
    
  end
end
