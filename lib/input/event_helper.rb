

class EventHelper

  attr_reader :player_hooks, :npc_hooks, :battle_layer_hooks, :battle_active_hooks,
    :menu_active_hooks, :menu_killed_hooks, :always_on_hooks
  def initialize(game, always_on_hooks, menu_killed_hooks, menu_active_hooks, battle_hooks, battle_layer_hooks_config, player_hooks, npc_hooks)
    @game = game

    @always_on_hooks_config = always_on_hooks
    @menu_killed_hooks_config = menu_killed_hooks
    @menu_active_hooks_config = menu_active_hooks
    @battle_hooks_config = battle_hooks
    @battle_layer_hooks_config = battle_layer_hooks_config
    @player_hooks_config = player_hooks
    @npc_hooks_config = npc_hooks
    rebuild_event_hooks
  end

  def accumulate_hooks_from_config(cfg)
    hooks = []
    cfg.each {|hook|
      hooks << @game.append_hook(hook)
    }
    hooks
  end

  def rebuild_event_hooks
    #TODO these should probably occasionally not target game.. not really urgent
    @always_on_hooks = accumulate_hooks_from_config(@always_on_hooks_config)
    @menu_killed_hooks = accumulate_hooks_from_config(@menu_killed_hooks_config)
    @menu_active_hooks = accumulate_hooks_from_config(@menu_active_hooks_config)
    @battle_active_hooks = accumulate_hooks_from_config(@battle_hooks_config)

    @battle_layer_hooks = accumulate_hooks_from_config(@battle_layer_hooks_config)
    @npc_hooks = accumulate_hooks_from_config(@npc_hooks_config)
    @player_hooks = accumulate_hooks_from_config(@player_hooks_config)

    remove_menu_active_hooks
    remove_battle_active_hooks
  end
  def non_menu_hooks
    (@npc_hooks + @player_hooks + @menu_killed_hooks).flatten
  end

  def remove_menu_active_hooks
    remove_hooks(@menu_active_hooks)
  end
  def remove_battle_active_hooks
    remove_hooks(@battle_active_hooks)
  end

  def remove_hooks(hooks)
    hooks.each {|hook| @game.remove_hook(hook)}
  end
end

