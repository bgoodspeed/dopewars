
class BattleParticipantCursorTextRenderingConfig < TextRenderingConfig

  def initialize(klasses, xc,xf,yc,yf)
    super(xc,xf,yc,yf)
    @klasses = klasses
  end

  def matches_menu_action?(ma)
    @klasses.include?(ma.class)
  end

  def cursor_offsets_at(position, game, menu_action)
    if matches_menu_action?(menu_action)
      offset = game.current_battle_participant_offset(position)
    else
      offset = [GameSettings::BATTLE_INVENTORY_XC + GameSettings::BATTLE_INVENTORY_XF * position, GameSettings::BATTLE_INVENTORY_YC + GameSettings::BATTLE_INVENTORY_YF * position]
    end
    offset
  end
end
