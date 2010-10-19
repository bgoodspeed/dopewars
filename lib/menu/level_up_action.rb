
class LevelUpAction < AbstractActorMenuAction

  def size
    2 #TODO this should come from the size of the attribute set
  end

  alias_method :details, :display_actor_status_info

  def activate(cursor_position, game, section_position, subsection_position=nil, option_position=nil)
    @menu_helper.set_active_subsection(section_position)
    if !subsection_position.nil?
      @actor.consume_level_up(subsection_position)
    end
    false
  end


end