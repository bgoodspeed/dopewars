
class HeroWrapper
  def initialize(game, item, member)
    @game = game
    @item = item
    @member = member
  end

  def name
    @member.name
  end
  def section_by_index(idx)
    self  #TODO this is odd..
  end

end

class InventoryDisplayWrapper
  def initialize(game, item)
    @game = game
    @item = item
  end
  def party_members
    @game.party_members
  end

  def section_by_index(idx)
    HeroWrapper.new(@game, @item, party_members[idx])
  end

end

class InventoryDisplayAction
  include Rubygame

  attr_reader :text
  alias_method :name, :text 
  def initialize(text, game, menu_helper)
    @text = text
    @game = game
    @menu_helper = menu_helper
    @selected_option = nil
  end

  def has_subsections?
    true
  end

  def section_by_index(idx)
    InventoryDisplayWrapper.new(@game, info[idx])
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

  def option_at(idx=nil)
    if idx.nil?
      party_members
    else
      party_members[idx]
    end
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

  def draw(menu_layer_config, game, text_rendering_helper, layer, screen)
    details.blit(layer, menu_layer_config.details_inset_on_layer)
  end

end