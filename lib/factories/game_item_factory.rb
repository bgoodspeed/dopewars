
class GameItemFactory
  def self.potion
    GameItem.new("potion", ItemState.new( ItemAttributes.none, 0, 10 ))
  end

  def self.antidote
    GameItem.new("antidote", ItemState.new(ItemAttributes.none, 0, 20 ))
  end

  def self.sword
    EquippableGameItem.new("sword", ItemState.new(ItemAttributes.new(0,0,1,0,0,0,0,0), 0, 20 ))
  end

end
