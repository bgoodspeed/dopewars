class WorldWeapon

  attr_reader :ticks, :max_ticks
  def initialize(pallette, max_ticks=25)
    @pallette = pallette
    @ticks = 0
    @max_ticks = max_ticks
  end
  def displayed
    @ticks += 1
  end

  def die
    @ticks = 0
  end
  def fired_from(px, py,facing)
    @startx = px
    @starty = py
    @facing = facing
  end

  def consumption_ratio
    @ticks.to_f/@max_ticks.to_f
  end

  def consumed?
    @ticks >= @max_ticks
  end

  def draw_weapon(screen)
  end
end
