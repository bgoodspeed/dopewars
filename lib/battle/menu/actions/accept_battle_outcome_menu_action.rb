# To change this template, choose Tools | Templates
# and open the template in the editor.

class AcceptBattleOutcomeMenuAction < MenuAction
  include BattleSelectorDependencyHelper

  def initialize(game)
    super(game,
          "Battle Spoils", 
          [ BattleAcceptSpoilsMenuSelector.new(game)])

  end

end
