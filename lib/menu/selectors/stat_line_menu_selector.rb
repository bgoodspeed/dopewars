# To change this template, choose Tools | Templates
# and open the template in the editor.

class StatLine
  attr_reader :name
  def initialize(name)
    @name = name
  end
end

class StatLineMenuSelector
  attr_accessor :menu_item

  def initialize(game)
    @game = game
  end

  def elements(selections)
    selections.selected_party_member.status_info.collect {|s| StatLine.new(s)}
  end

  def selection_type
    StatLine
  end

  def size(selections)
    elements(selections).size
  end

  def element_names(selections)
    elements(selections).collect {|el| el.name }
  end

  def select_element_at(idx, selections)
    raise "fucking hell" if idx.nil?
    elements(selections)[idx]
  end

  alias_method :element_at, :select_element_at

  def draw(config, text_rendering_helper, selections)
    member_names = elements(selections).collect {|m| m.name}
    text_rendering_helper.render_lines_to_layer( member_names, config)
  end

end
