# To change this template, choose Tools | Templates
# and open the template in the editor.

class SaveGameMenuAction
   attr_reader :dependencies, :name, :game
   include SelectorDependencyHelper

   def initialize(game)
    @game = game
    @name = "Save"
    @dependencies = [
      SaveSlotMenuSelector.new(game)
    ]
  end

end
