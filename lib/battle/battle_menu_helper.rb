class BattleMenuHelper < MenuHelper
  def initialize(battle, screen, layer,text_helper, sections, cursor_x, cursor_y, cursor_main_color=:blue, cursor_inactive_color=:white)
    super(screen, layer,text_helper, sections, cursor_x, cursor_y, cursor_main_color, cursor_inactive_color)
    @battle = battle
  end

  def current_cursor_member_ready?
    @battle.party.members[@cursor_position].ready?
  end

  def color_for_current_section_cursor
    if current_cursor_member_ready?
      @cursor_main_color
    else
      @cursor_inactive_color
    end
  end
  def enter_current_cursor_location(game)
    super(game) if current_cursor_member_ready?
  end


end
