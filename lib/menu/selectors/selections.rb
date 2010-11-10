# To change this template, choose Tools | Templates
# and open the template in the editor.

class Selections
  def size
    @selected.size
  end
  def initialize
    @selected = []
  end
  def <<(other)
    @selected << other
  end

  def first
    @selected.first
  end

  def satisfy?(selector)
    !search_selected_for(selector.selection_type).nil?
  end

  def has_selected?(klass)
    !search_selected_for(klass).nil?
  end

  def search_selected_for(klass)
    found = @selected.select {|s| s.is_a? klass} #TODO this logic could be a bit more flexible
    found.empty? ? nil : found.first
  end

  def get_selected_type(type, msg)
    found = search_selected_for(type)
    raise "Required selection of #{msg} not performed" if found.nil?
    found
  end

  def selected_party_member
    get_selected_type(Hero, "party member")
  end
  def selected_inventory_item
    get_selected_type(InventoryItem, "inventory item")
  end

  def drop_last
    @selected = @selected.slice(0,@selected.size - 1)
  end
end
