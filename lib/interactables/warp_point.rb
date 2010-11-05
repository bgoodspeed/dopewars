

class WarpPoint
  attr_accessor :destination

  def is_blocking?
    false
  end

  def initialize(dest_index, dest_x=nil, dest_y=nil)
    @destination = dest_index
    @destination_x = dest_x
    @destination_y = dest_y
  end

  def activate(game, player, worldstate, tilex, tiley)
    uni = player.universe
    player.universe.fade_out_bg_music
    player.universe.play_sound_effect(SoundEffect::WARP)
    player.set_position(@destination_x, @destination_y)
    uni.set_current_world_by_index(@destination)
    player.universe.fade_in_bg_music
  end
  include JsonHelper
  def json_params
    [ @destination]
  end
end