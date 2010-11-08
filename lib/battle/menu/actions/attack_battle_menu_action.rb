# To change this template, choose Tools | Templates
# and open the template in the editor.

class AttackBattleMenuAction < MenuAction
  include BattleSelectorDependencyHelper

  def initialize(game)
    super(game, "Attack",[
      BattleReadyPartyMenuSelector.new(game),
      BattleTargetsMenuSelector.new(game)
    ])
  end
end
