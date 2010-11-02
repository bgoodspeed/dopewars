# To change this template, choose Tools | Templates
# and open the template in the editor.
class InventoryFilter
  attr_reader :name
  def initialize(name="All Items")
    @name = name
  end
end

class KeyItemInventoryFilter < InventoryFilter
  def initialize
    super("Key Items")
  end

end

class InventoryFilterMenuSelector
  attr_accessor :menu_item
  def initialize(game)
    @game = game
  end

  #TODO unit test the key matching selections -- make sure both Key/Inventory filters are recognized
  def selection_type
    InventoryFilter
  end

  def filters
    [InventoryFilter.new, KeyItemInventoryFilter.new]
  end
  alias_method :elements, :filters
  def select_element_at(idx, selections)
    elements[idx]
  end
  def element_names(selections)
    elements.collect {|el| el.name }
  end


  alias_method :element_at, :select_element_at
  def size(selectios=nil)
    filters.size
  end
  def draw(config, text_rendering_helper, currently_selected)
    member_names = elements.collect {|m| m.name}
    text_rendering_helper.render_lines_to_layer( member_names, config)
  end


end
