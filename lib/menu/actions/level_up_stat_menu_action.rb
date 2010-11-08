# To change this template, choose Tools | Templates
# and open the template in the editor.

class LevelUpStatMenuAction < MenuAction
 def initialize(game)
    super(game, "Level Up",[
      PartyMenuSelector.new(game),
      StatLineMenuSelector.new(game)
    ])

  end
end
