# To change this template, choose Tools | Templates
# and open the template in the editor.


class StatLineInfoMenuAction < MenuAction
   def initialize(game, name = "Status")
    super(game, name,[
      PartyMenuSelector.new(game),
      StatLineMenuSelector.new(game)
    ])
   end

end
