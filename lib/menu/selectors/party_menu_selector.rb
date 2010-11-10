# To change this template, choose Tools | Templates
# and open the template in the editor.

class PartyMenuSelector
  extend Forwardable
  include DrawableElementMenuSelectorHelper
  attr_accessor :menu_item

  def_delegators :@menu_item, :name
  def initialize(game)
    @game = game
  end

  def size(selections=nil)
    elements(selections).size
  end

  def elements(selections)
    @game.party_members
  end

  def selection_type
    Hero
  end



end
