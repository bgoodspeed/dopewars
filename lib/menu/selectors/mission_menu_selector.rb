# To change this template, choose Tools | Templates
# and open the template in the editor.

class MissionMenuSelector
  include DrawableElementMenuSelectorHelper
  
  def initialize(game)
    @game = game
  end

  def selection_type
    Mission
  end

  def size(selections=nil)
    elements(selections).size
  end

  def elements(selections)
    @game.player_missions
  end


end
