# To change this template, choose Tools | Templates
# and open the template in the editor.

class BattleReadyPartyMenuSelector
  include DrawableElementMenuSelectorHelper
  def initialize(game)
    @game = game
  end

  def elements
    @game.battle_ready_party_members
  end
end
