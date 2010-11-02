# To change this template, choose Tools | Templates
# and open the template in the editor.

class LevelUpStatMenuAction
  attr_reader :dependencies, :name, :game
  include SelectorDependencyHelper
  def initialize(game)
    @game = game
    @name = "Level Up"
    @dependencies = [
      PartyMenuSelector.new(game),
      StatLineMenuSelector.new(game)
    ]

  end


end
