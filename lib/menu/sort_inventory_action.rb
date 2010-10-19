
class SortInventoryAction
  attr_reader :text
  def initialize(text, game, menu_helper)
    @text = text
    @game = game
    @menu_helper = menu_helper
  end
  def activate(cursor_position, game, section_position)
    puts "TODO re-sort inventory"
  end



end