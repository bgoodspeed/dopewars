
class EquippableGameItem < GameItem
  def equippable?
    true
  end
  def consumeable?
    false
  end

end