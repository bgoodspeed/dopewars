# To change this template, choose Tools | Templates
# and open the template in the editor.

class BattleTargetsMenuSelector
  include DrawableElementMenuSelectorHelper

  def initialize(game)
    @game = game
  end

  def elements
    @game.battle_members
  end

end
