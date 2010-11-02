# To change this template, choose Tools | Templates
# and open the template in the editor.

module BattleSelectorDependencyHelper
  include BaseSelectorDependencyHelper
  def text_rendering_helper_from(game)
     game.battle_layer.text_rendering_helper
  end

end
