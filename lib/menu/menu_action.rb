
class MenuAction
  attr_reader :text
  alias_method :name, :text
  def initialize(text, action=NoopAction.new)
    @text = text
    @action = action
  end

  def activate(main_menu_idx, game, submenu_idx)
    puts "This is a no-op action: #{@text}"
  end
end

