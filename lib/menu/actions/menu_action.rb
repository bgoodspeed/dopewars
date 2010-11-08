# To change this template, choose Tools | Templates
# and open the template in the editor.

class MenuAction
  include SelectorDependencyHelper

  def initialize(game, name, dependencies)
    @game = game
    @name = name
    @dependencies = dependencies
  end
end
