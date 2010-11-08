# To change this template, choose Tools | Templates
# and open the template in the editor.

class UseItemMenuAction < MenuAction
  attr_reader :dependencies, :name, :game
  include SelectorDependencyHelper

  def initialize(game, action=ItemAction.new)
    super(game, "Items", [
      InventoryFilterMenuSelector.new(game),
      FilteredInventoryMenuSelector.new(game),
      PartyMenuSelector.new(game)
    ])
    @action = action
  end

  def invoke(selections)
    item = selections.selected_inventory_item
    dest = selections.selected_party_member
    src = dest
    raise "something happened to item" if item.nil?
    raise "something happened to dest" if dest.nil?
    raise "something happened to src" if src.nil?
    @action.perform(src, dest, item)
  end

end
