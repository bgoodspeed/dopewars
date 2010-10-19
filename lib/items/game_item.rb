
class GameItem
  attr_reader :state, :name
  alias_method :effects,:state
  def initialize(name, state)
    @name = name
    @state = state
  end

  def to_s
    @name
  end

  def equippable?
    false
  end

  def consumeable?
    true
  end

end