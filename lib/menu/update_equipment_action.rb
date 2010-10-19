
class UpdateEquipmentAction < AbstractActorMenuAction

  def initialize(actor, menu_helper, game)
    super(actor, menu_helper)
    @game = game
  end

  def activate(cursor_position, game, section_position, subsection_position=nil, option_position=nil)
    @menu_helper.set_active_subsection(section_position)
    unless option_position.nil?
      new_gear = inventory[option_position]

      @actor.equip_in_slot_index(subsection_position, new_gear)
    end
    true
  end

  def option_at(idx)
    inventory
  end

  def equipment
    @actor.equipment_info
  end
  def details
    info_lines = equipment
    s = Surface.new([@@STATUS_WIDTH, @@STATUS_HEIGHT])
    s.fill(:yellow)
    @menu_helper.render_text_to(s, info_lines, TextRenderingConfig.new(0, 0, 0,@@MENU_LINE_SPACING))
    s
  end

  def inventory
    @game.inventory.inventory_info
  end

  def surface_for(posn)
    info_lines = inventory.collect {|i| i.to_info}
    s = Surface.new([@@STATUS_WIDTH, @@STATUS_HEIGHT])
    s.fill(:yellow)
    @menu_helper.render_text_to(s, info_lines, TextRenderingConfig.new(0, 0, 0,@@MENU_LINE_SPACING))
    s
  end

  def size
    @actor.equipment_info.size
  end


end
