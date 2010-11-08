# To change this template, choose Tools | Templates
# and open the template in the editor.

class LoadGameMenuAction < MenuAction
  def initialize(game)
    super(game, "Load",[
      SaveSlotMenuSelector.new(game)
    ])
  end

end
