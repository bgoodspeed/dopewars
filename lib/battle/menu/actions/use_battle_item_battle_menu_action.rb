# To change this template, choose Tools | Templates
# and open the template in the editor.

class UseBattleItemBattleMenuAction < MenuAction
  include BattleSelectorDependencyHelper

  def initialize(game)
    super(game,"Items" ,[
      BattleReadyPartyMenuSelector.new(game),
      BattleFilteredInventoryMenuSelector.new(game),
      BattleTargetsMenuSelector.new(game)
    ])
  end
end
