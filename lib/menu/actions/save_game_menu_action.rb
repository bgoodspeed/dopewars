# To change this template, choose Tools | Templates
# and open the template in the editor.

class SaveGameMenuAction < MenuAction
   def initialize(game)
    super(game,"Save", [
      SaveSlotMenuSelector.new(game)
    ])
  end

end
