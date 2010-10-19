

class AbstractActorMenuAction
  extend Forwardable
  def initialize(actor, menu_helper)
    @actor = actor
    @menu_helper = menu_helper
  end
  def text
    @actor.name
  end
  def display_actor_status_info
    info_lines = @actor.status_info
    s = Surface.new([@@STATUS_WIDTH, @@STATUS_HEIGHT])
    s.fill(:green)
    @menu_helper.render_text_to(s, info_lines, TextRenderingConfig.new(0, 0, 0,@@MENU_LINE_SPACING))
    s
  end

end
