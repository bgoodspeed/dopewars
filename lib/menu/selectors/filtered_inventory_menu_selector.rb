# To change this template, choose Tools | Templates
# and open the template in the editor.

class FilteredInventoryMenuSelector
  include DrawableElementMenuSelectorHelper
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

  def elements(selected)
    filter(@game.inventory_info, selected)
  end

  def select_element_at(idx, selections)
    rv = elements[idx]
    rv
  end

 end
