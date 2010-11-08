# To change this template, choose Tools | Templates
# and open the template in the editor.

class BattleMenuAction < MenuAction
  include BattleSelectorDependencyHelper

  def initialize(game, name, middle_selectors)
    @first_selector = BattleReadyPartyMenuSelector.new(game)
    @last_selector = BattleTargetsMenuSelector.new(game)
    super(game, name, [@first_selector] + middle_selectors + [@last_selector])
    
  end
end
