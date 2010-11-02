# To change this template, choose Tools | Templates
# and open the template in the editor.




class StatLineInfoMenuAction
   attr_reader :dependencies, :name, :game
   include SelectorDependencyHelper

   def initialize(game)
    @game = game
    @dependencies = [
      PartyMenuSelector.new(game),
      StatLineMenuSelector.new(game)
    ]
    @name = "Status"
   end

end
