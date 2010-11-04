# To change this template, choose Tools | Templates
# and open the template in the editor.

class MissionInfoMenuAction
  attr_reader :dependencies, :name, :game
  include SelectorDependencyHelper

  def initialize(game)
    @game = game
    @name = "Missions"
    @dependencies = [
      MissionMenuSelector.new(game)
    ]
    
  end
end
