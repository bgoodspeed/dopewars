# To change this template, choose Tools | Templates
# and open the template in the editor.

class SaveSlot
  attr_reader :name, :filename
  def initialize(name, filename, idx)
    @name = name
    @filename = filename
  end
end

class SaveSlotMenuSelector
  attr_accessor :menu_item

  @@NUM_SLOTS = 5

  def initialize(game)
    @game = game
  end

  def selection_type
    SaveSlot
  end

  def elements
    (0..@@NUM_SLOTS).collect {|i| save_slot(i)}
  end
  def save_slot(idx)
    SaveSlot.new("Slot #{idx + 1}" ,"save-slot-#{idx}.json", idx)
  end
  def select_element_at(idx, selections)
    elements[idx]
  end

  alias_method :element_at, :select_element_at
  def draw(config, text_rendering_helper, currently_selected)
    member_names = elements.collect {|m| m.name}
    text_rendering_helper.render_lines_to_layer( member_names, config)
  end

end
