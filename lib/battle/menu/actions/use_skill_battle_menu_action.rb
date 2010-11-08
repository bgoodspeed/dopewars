# To change this template, choose Tools | Templates
# and open the template in the editor.

class UseSkillBattleMenuAction < BattleMenuAction
  def initialize(game)
    super(game, "Skills", [BattleSkillMenuSelector.new(game)])
  end
end
