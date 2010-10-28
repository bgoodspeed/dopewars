

class AbstractActorMenuAction
  include Rubygame
  extend Forwardable
  def initialize(actor, menu_helper)
    @actor = actor
    @menu_helper = menu_helper
  end
  def text
    @actor.name
  end
  def section_by_index(idx)
    puts "hrm, maybe should be picking a certain status line"
  end
  def display_actor_status_info
    info_lines = @actor.status_info
    s = Surface.new([@@STATUS_WIDTH, @@STATUS_HEIGHT])
    s.fill(:green)
    @menu_helper.render_text_to(s, info_lines, TextRenderingConfig.new(0, 0, 0,@@MENU_LINE_SPACING))
    s
  end
  def has_subsections?
    true
  end


  def draw(menu_layer_config, game, text_rendering_helper, layer, screen)
    display_actor_status_info.blit(layer, menu_layer_config.details_inset_on_layer)
  end

  alias_method :name, :text
end
