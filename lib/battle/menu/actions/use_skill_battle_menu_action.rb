# To change this template, choose Tools | Templates
# and open the template in the editor.

class UseSkillBattleMenuAction
 attr_reader :dependencies, :name, :game
 include BattleSelectorDependencyHelper


  def initialize(game)
    @game = game
    @name = "Skills"
    @dependencies = [
      BattleReadyPartyMenuSelector.new(game),
      BattleSkillMenuSelector.new(game),

      BattleTargetsMenuSelector.new(game)
    ]
  end
end
