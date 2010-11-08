# To change this template, choose Tools | Templates
# and open the template in the editor.

class UseSkillBattleMenuAction < MenuAction
  include BattleSelectorDependencyHelper

  def initialize(game)
    super(game, "Skills", [
      BattleReadyPartyMenuSelector.new(game),
      BattleSkillMenuSelector.new(game),
      BattleTargetsMenuSelector.new(game)
    ])
  end
end
