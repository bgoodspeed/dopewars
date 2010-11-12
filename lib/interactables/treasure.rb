class Treasure
  attr_accessor :name
  def is_blocking?
    true
  end
  def initialize(name)
    @name = name
  end

  def activate(game, player, worldstate, tilex, tiley)
    game.universe.play_sound_effect(SoundEffect::TREASURE)
    worldstate.update_interaction_map(tilex, tiley, GameSettings::OPEN_TREASURE)
    player.add_inventory(1, @name)
    game.add_notification(WorldScreenNotification.new("Got #{@name}"))
  end

  include JsonHelper
  def json_params
    [ @name]
  end
end