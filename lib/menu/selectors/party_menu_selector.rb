# To change this template, choose Tools | Templates
# and open the template in the editor.

class PartyMenuSelector
  extend Forwardable

  attr_accessor :menu_item

  def_delegators :@menu_item, :name
  def initialize(game)
    @game = game
  end

  def size(selections=nil)
    elements.size
  end

  def party_members
    @game.party_members
  end

  def selection_type
    Hero
  end

  def select_element_at(idx, selections)
    rv = elements[idx]
    raise "invalid party member selection: #{idx} of #{elements.size}" if rv.nil?
    rv
  end

  alias_method :elements, :party_members
  def element_at(idx, selections)
    rv = elements[idx]
    raise "invalid party member selection: #{idx} of #{elements.size}" if rv.nil?
    rv
  end

  def element_names(selections)
    elements.collect {|e| e.name}
  end

  def draw(config, text_rendering_helper, currently_selected)
    member_names = elements.collect {|m| m.name}
    text_rendering_helper.render_lines_to_layer( member_names, config)
  end

end
