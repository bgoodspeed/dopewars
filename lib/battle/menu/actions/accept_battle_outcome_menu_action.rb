# To change this template, choose Tools | Templates
# and open the template in the editor.

class AcceptBattleOutcomeMenuAction
  attr_reader :dependencies, :name, :game
  include BattleSelectorDependencyHelper

  def initialize(game)
    @game = game
    @name = "Battle Spoils"
    @dependencies = [
      BattleAcceptSpoilsMenuSelector.new(game)
    ]
  end
end
