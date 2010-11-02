module SelectorDependencyHelper
  include BaseSelectorDependencyHelper
  def text_rendering_helper_from(game)
     game.menu_layer.text_rendering_helper
  end

end