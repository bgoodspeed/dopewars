# To change this template, choose Tools | Templates
# and open the template in the editor.

class FleeBattleMenuAction
  attr_reader :dependencies, :name, :game
  include BattleSelectorDependencyHelper

  def initialize(game)
    @game = game
    @name = "Flee"
    @dependencies = [
      BattleReadyPartyMenuSelector.new(game)
    ]
  end
  
end
