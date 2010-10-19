
class InventoryDisplayAction
  attr_reader :text
  def initialize(text, game, menu_helper)
    @text = text
    @game = game
    @menu_helper = menu_helper
    @selected_option = nil
  end

  def activate(cursor_position, game, section_position, subsection_position=nil, option_position=nil)
    if !option_position.nil?
      item = info[subsection_position]
      target = party_members[option_position]
      target.consume_item(item) #TODO this is similar to ItemAction refactor
    elsif subsection_position.nil?
      @menu_helper.set_active_subsection(section_position)
    end
    return !subsection_position.nil?
  end
  def surface_for(posn)
    item = info[posn]
    s = Surface.new([@@STATUS_WIDTH, @@STATUS_HEIGHT])
    s.fill(:white)
    member_names = party_members.collect {|m| m.name}
    @menu_helper.render_text_to(s,member_names , TextRenderingConfig.new(0, 0, 0,@@MENU_LINE_SPACING))
    s

  end

  def option_at(idx)
    party_members
  end

  def party_members
    @game.party_members
  end

  def info
    @game.inventory_info
  end

  def details
    info_lines = info.collect {|item| item.to_info}
    s = Surface.new([@@STATUS_WIDTH, @@STATUS_HEIGHT])
    s.fill(:yellow)
    @menu_helper.render_text_to(s, info_lines, TextRenderingConfig.new(0, 0, 0,@@MENU_LINE_SPACING))
    s
  end

  def size
    info.size
  end
end