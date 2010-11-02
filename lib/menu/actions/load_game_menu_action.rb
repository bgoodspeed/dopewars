# To change this template, choose Tools | Templates
# and open the template in the editor.

class LoadGameMenuAction
   attr_reader :dependencies, :name, :game
   include SelectorDependencyHelper
  def initialize(game)
    @game = game
    @name = "Load"
    @dependencies = [
      SaveSlotMenuSelector.new(game)
    ]
  end

end
