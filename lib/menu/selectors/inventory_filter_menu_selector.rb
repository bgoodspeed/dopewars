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
  include DrawableElementMenuSelectorHelper
  attr_accessor :menu_item
  def initialize(game)
    @game = game
  end

  #TODO unit test the key matching selections -- make sure both Key/Inventory filters are recognized
  def selection_type
    InventoryFilter
  end

  def elements(selections)
    [InventoryFilter.new, KeyItemInventoryFilter.new]
  end

  alias_method :element_at, :select_element_at


end
