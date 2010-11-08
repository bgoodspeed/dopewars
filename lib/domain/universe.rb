
class Universe
  attr_reader :worlds, :current_world,  :current_world_idx, :game_layers, :sound_effects, :game

  alias_method :world_number, :current_world_idx
  extend Forwardable
  def_delegators :@sound_effects, :play_sound_effect
  def_delegators :@current_world, :interpret, :npcs, :blit_world, :toggle_bg_music, 
    :fade_out_bg_music, :fade_in_bg_music, :monsters, :x_offset_for_world, :y_offset_for_world,
    :x_offset_for_interaction, :y_offset_for_interaction
  def_delegators :@game_layers, :dialog_layer, :menu_layer, :battle_layer, :notifications_layer,
    :draw_game_layers_if_active, :menu_move_cursor_up, :menu_move_cursor_down, :menu_cancel_action,
    :battle_cancel_action, :battle_move_cursor_down, :battle_move_cursor_up, :add_notification,
    :reset_menu_positions, :current_battle_participant_offset, :notifications,
    :current_selected_menu_entry_name, :current_menu_entries

  def initialize(current_world_idx, worlds, game_layers=nil, sound_effects=nil, game=nil)
    raise "must have at least one world" if worlds.empty?
    @current_world = worlds[current_world_idx]
    @current_world_idx = current_world_idx
    @worlds = worlds
    @game_layers = game_layers
    @sound_effects = sound_effects
    @game = game #TODO this makes the model circular... maybe a problem?
  end

  def world_by_index(idx)
    @worlds[idx]
  end

  def set_current_world(world)
    @current_world = world
  end

  def set_current_world_by_index(idx)
    @current_world_idx = idx
    set_current_world(world_by_index(idx))
  end

  def reblit_backgrounds
    @worlds.each {|world| world.reblit_background}
  end

  def replace_world_data(orig_uni)
    worlds_with_index(orig_uni) {|world, orig_world|
      world.replace_pallettes(orig_world)
      world.replace_bgsurface(orig_world)
      world.replace_bgmusic(orig_world)
    }
  end

  def worlds_with_index(orig_uni)
    @worlds.each_with_index do |world, index|
      orig_world = orig_uni.world_by_index(index)
      yield world, orig_world
    end
  end

  include JsonHelper
  def json_params
    [ @current_world_idx, @worlds]
  end
end
