# To change this template, choose Tools | Templates
# and open the template in the editor.

class FleeBattleMenuAction < MenuAction
  include BattleSelectorDependencyHelper

  def initialize(game)
    super(game, "Flee",[
      BattleReadyPartyMenuSelector.new(game)
    ])
  end
      
  
end
