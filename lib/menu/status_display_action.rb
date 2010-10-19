

class StatusDisplayAction < AbstractActorMenuAction
  def size
    1
  end


  def activate(cursor_position, game, section_position, subsection_position=nil, option_position=nil)
    @menu_helper.set_active_subsection(section_position)
    false
  end

  alias_method :details, :display_actor_status_info
end