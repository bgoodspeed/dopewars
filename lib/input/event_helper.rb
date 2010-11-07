

class EventHelper
  include Rubygame
  include Rubygame::Events
  include Rubygame::EventTriggers

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

  def rebuild_event_hooks
    @always_on_hooks = @game.make_magic_hooks(@always_on_hooks_config)
    @menu_killed_hooks = @game.make_magic_hooks(@menu_killed_hooks_config)
    @menu_active_hooks = @game.make_magic_hooks(@menu_active_hooks_config)
    @battle_active_hooks = @game.make_magic_hooks(@battle_hooks_config)

    @battle_layer_hooks = []
    @battle_layer_hooks_config.each {|hook|
      @battle_layer_hooks << @game.append_hook(hook)
    }
    

    @npc_hooks = []
    @npc_hooks_config.each {|hook|
      @npc_hooks << @game.append_hook(hook)
    }

    @player_hooks = []
    @player_hooks_config.each {|hook|
      @player_hooks << @game.append_hook(hook)
    }



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

