
class EndBattleMenuAction < MenuAction
  def initialize(text, battle_layer)
    super(text)
    @battle_layer = battle_layer
  end

  def activate(menu_idx, game, submenu_idx)
    @battle_layer.end_battle
  end
end
