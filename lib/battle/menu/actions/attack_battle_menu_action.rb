# To change this template, choose Tools | Templates
# and open the template in the editor.

class AttackBattleMenuAction
 attr_reader :dependencies, :name, :game
 include BattleSelectorDependencyHelper


  def initialize(game)
    @game = game
    @name = "Attack"
    @dependencies = [
      BattleReadyPartyMenuSelector.new(game),
      BattleTargetsMenuSelector.new(game)
    ]
  end
end
