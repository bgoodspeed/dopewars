
class Hud
include Rubygame
include Rubygame::Events
include FontLoader

  # construct the HUD
  def initialize options
    @screen = options[:screen]  # need that to blit on it
    @player = options[:player]
    @topomap = options[:topomap]
    @cosmic_font = load_font("FreeSans.ttf")
    @time = "-"

  end

  # called from the game class in each loop. updates options that are displayed
  def update options
    @time = options[:time]
  end

  # called from the game class in the draw method. render any options
  # and blit the surface on the screen
  def draw
    timer = @cosmic_font.render @time.to_s, true, [123,123,123]
    timer.blit @screen, [@screen.w-timer.w-6, 6]   # blit to upper right corner
  end

end