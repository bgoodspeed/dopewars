class BattleHud
  def initialize(screen, text_rendering_helper, layer, surface_factory=SurfaceFactory.new)
    @screen = screen
    @text_rendering_helper = text_rendering_helper
    @layer = layer
    @surface_factory = surface_factory
    @sub_surface = @surface_factory.make_surface([10, 10])
    @surface = @surface_factory.make_surface([500, 50])
  end

  def map_to_colors(rate)
    r = rate.to_i
    1.upto(10).collect {|i| i <= r ? :blue : :red }
  end

  def fill_in_sub(s, sub, color, hi, idx, ready_colors)
    sub.fill(color)
    sub.blit(s, [hi * 100 + idx * 10, 5])
    sub.fill(ready_colors[idx])
    sub.blit(s, [hi * 100 + idx * 10, 25])
  end

  def health_rates(heroes)
    heroes.collect {|h| h.hp_ratio * 10}
  end
  def ready_rates(heroes)
    heroes.collect {|h| h.ready_ratio * 10}
  end

  def build_sub(s,hr,hi,heroes)
    colors = map_to_colors(hr)
    ready_colors = map_to_colors(ready_rates(heroes)[hi])
    colors.each_with_index do |color, idx|
      fill_in_sub(s, @sub_surface, color, hi, idx, ready_colors)
    end
  end

  def draw(menu_layer_config, game, battle)
    heroes = battle.heroes

    @surface.fill(:green)
    health_rates(heroes).each_with_index do |hr, hi|
      build_sub(@surface, hr, hi, heroes)
    end
    @surface.blit(@screen, [40,400])

  end

end
