# To change this template, choose Tools | Templates
# and open the template in the editor.

class FilteredInventoryMenuSelector
  attr_accessor :menu_item
  def initialize(game)
    @game = game
  end

  def selection_type
    InventoryItem
  end

  def filter(what, selections)
    #TODO use #{@filter_selector} and #{selections} to reduce the size of #{what}
    what
  end
  def element_names(selections)
    elements(selections).collect {|e| e.name }
  end
  def size(selections=nil)
    elements(selections).size
  end

  def elements(selected=[])
    filter(@game.inventory_info, selected)
  end

  def select_element_at(idx, selections)
    rv = elements[idx]
    puts "rv is a #{rv}"
    rv
  end

  alias_method :element_at, :select_element_at

  def draw(config, text_rendering_helper, currently_selected)

    member_names = elements(currently_selected).collect {|m| m.name}
    text_rendering_helper.render_lines_to_layer( member_names, config)
  end



 end
