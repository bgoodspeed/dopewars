class BattleHud
  include Rubygame

  def initialize(screen, text_rendering_helper, layer, surface_factory=SurfaceFactory.new)
    @screen = screen
    @text_rendering_helper = text_rendering_helper
    @layer = layer
    @surface_factory = surface_factory
  end

  def map_to_colors(rate)
    r = rate.to_i
    1.upto(10).collect {|i| i <= r ? :blue : :red }
  end

  def draw(menu_layer_config, game, battle)
    heroes = battle.heroes
    hpr = heroes.collect {|h| h.hp_ratio}
    health_rates = heroes.collect {|h| h.hp_ratio * 10}
    ready_rates = heroes.collect {|h| h.ready_ratio * 10}

    s = @surface_factory.make_surface([500, 50])
    s.fill(:green)
    health_rates.each_with_index do |hr, hi|
      sub = @surface_factory.make_surface([10, 10])
      colors = map_to_colors(hr)
      ready_colors = map_to_colors(ready_rates[hi])
      colors.each_with_index do |color, idx|
        sub.fill(color)
        sub.blit(s, [hi * 100 + idx * 10, 5])
        sub.fill(ready_colors[idx])
        sub.blit(s, [hi * 100 + idx * 10, 25])
      end
    end
    s.blit(@screen, [40,400])

  end

end
