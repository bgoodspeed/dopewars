

class EventHelper
  include Rubygame
  include Rubygame::Events
  include Rubygame::EventTriggers

  attr_reader :player_hooks, :npc_hooks, :battle_layer_hooks, :battle_active_hooks,
    :menu_active_hooks, :menu_killed_hooks, :always_on_hooks
  def initialize(game, always_on_hooks, menu_killed_hooks, menu_active_hooks, battle_hooks)
    @game = game

    @always_on_hooks_config = always_on_hooks
    @menu_killed_hooks_config = menu_killed_hooks
    @menu_active_hooks_config = menu_active_hooks
    @battle_hooks_config = battle_hooks
    rebuild_event_hooks
  end

  def rebuild_event_hooks
    @always_on_hooks = @game.make_magic_hooks(@always_on_hooks_config)
    @menu_killed_hooks = @game.make_magic_hooks(@menu_killed_hooks_config)
    @menu_active_hooks = @game.make_magic_hooks(@menu_active_hooks_config)
    @battle_active_hooks = @game.make_magic_hooks(@battle_hooks_config)

    @battle_layer_hooks = @game.make_magic_hooks_for(@game.battle_layer, { YesTrigger.new() => :handle } )
    @npc_hooks = []
    @game.npcs.each {|npc|
      @npc_hooks << @game.make_magic_hooks_for( npc, { YesTrigger.new() => :handle } )
    }
    @player_hooks = @game.make_magic_hooks_for( @game.player, { YesTrigger.new() => :handle } )

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

