# To change this template, choose Tools | Templates
# and open the template in the editor.

class UseBattleItemBattleMenuAction
  attr_reader :dependencies, :name, :game
  include BattleSelectorDependencyHelper

  def initialize(game)
    @game = game
    @name = "Items"
    @dependencies = [
      BattleReadyPartyMenuSelector.new(game),
      BattleFilteredInventoryMenuSelector.new(game),
      BattleTargetsMenuSelector.new(game)
    ]
  end
end
