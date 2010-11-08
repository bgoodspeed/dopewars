
class Game
  attr_accessor :player, :universe, :screen

  def key_press_hooks(*pairs)
    pairs.collect{|pair| key_press_hook(pair[0], pair[1])}
  end

  def key_press_hook(keysym, target)
    @trigger_factory.make_key_press_event_hook(self, keysym, target)
  end

  def event_hook(owner, event_type, target)
    @trigger_factory.make_event_hook(owner, event_type, target)
  end

  def standard_keymap(left, down, right, up, enter, cancel)
    key_press_hooks([:left, left], [:down, down], [:right, right], [:up, up], [:i, enter], [:b, cancel])
  end

  def initialize()
    @factory = GameInternalsFactory.new
    @screen = @factory.make_screen
    
    world1 = @factory.make_world1
    world2 = @factory.make_world2
    world3 = @factory.make_world3
    @universe = @factory.make_universe([world1, world2, world3], @factory.make_game_layers(@screen, self), @factory.make_sound_effects, self) #XXX might be bad to pass self and make loops in the obj graph
#    @universe.toggle_bg_music #TODO turned this off because it was annoying me during testing

    @player = @factory.make_player(@screen, @universe, self)
    world1.add_npc(@factory.make_npc(@player, @universe))
    world1.add_npc(@factory.make_monster(@player, @universe))
    @hud = @factory.make_hud(@screen, @player, @universe)
    @trigger_factory = TriggerFactory.new

    #TODO FIXMENOW TODOFIXMENOW 
#    QuitRequestedFacade.quit_request_type => :quit, #TODO i'd rather not see direct references to facade objects, hide in a factory


    always_on_keymap = key_press_hooks( [:escape, :quit], [ :q, :quit],
        [ :c, :capture_ss], [ :d, :toggle_dialog_layer], [ :m, :toggle_menu], [ :p, :pause]
      )
    
    menu_killed_hooks = key_press_hooks( [ :i, :interact_with_facing],
        [ :space, :use_weapon], [ :b, :toggle_bg_music]
    )

    menu_active_hooks = standard_keymap(:menu_left, :menu_down, :menu_right, :menu_up, :menu_enter, :menu_cancel)
    battle_hooks = standard_keymap(:battle_left, :battle_down, :battle_right, :battle_up, :battle_enter, :battle_cancel)

    
    battle_layer_hooks = [
      event_hook(battle_layer, :tick, :update)
    ]

    player_hooks = [
      event_hook(player, :key_press, :key_pressed),
      event_hook(player, :key_release, :key_released),
      event_hook(player, :tick, :update)
    ]

    npc_hooks = npcs.collect {|npc|
      event_hook(npc, :tick, :update)
    }

    @event_handler = @trigger_factory.make_event_handler
    @event_system = @factory.make_event_system(self, always_on_keymap, menu_killed_hooks, menu_active_hooks, battle_hooks, battle_layer_hooks, player_hooks, npc_hooks)

#    @event_helper = @factory.make_event_hooks(self, always_on_hooks, menu_killed_hooks, menu_active_hooks, battle_hooks)
#    @clock = @factory.make_clock
#    @queue = @factory.make_queue

  end

  def go
    catch(:quit) do
      loop do
        step
      end
    end
  end

  def quit
    puts "Quitting!"
    throw :quit
  end

  def step_until(ticks)
    ticks.times do
      step
    end
  end

  def step_until_time(millisecs)
    time_of_death = @event_system.lifetime + millisecs
    while (@event_system.lifetime < time_of_death) do
      step
    end
  end

  def battle_begun(universe, player)
    toggle_battle_hooks(false)
  end
  def battle_completed
    toggle_battle_hooks(true)
    @player.clear_keys
  end


  def start_battle(monster)
    battle_layer.start_battle(self, monster)
  end

  def rebuild_hud
    @hud = @factory.make_hud(@screen, @player, @universe)
  end

  def all_hooks
    @event_handler.hooks.flatten
  end

  def remove_all_hooks
    all_hooks.each {|hook|
      remove_hook(hook)
    }
  end

  extend Forwardable

  def_delegator :@universe, :menu_cancel_action, :menu_cancel
  def_delegator :@universe, :menu_move_cursor_up, :menu_up
  def_delegator :@universe, :menu_move_cursor_down, :menu_down
  def_delegator :@universe, :menu_cancel_action, :menu_left

  def_delegator :@universe, :battle_cancel_action, :battle_down
  def_delegator :@universe, :battle_move_cursor_up, :battle_left
  def_delegator :@universe, :battle_move_cursor_down, :battle_right
  def_delegator :@universe, :battle_cancel_action, :battle_cancel
  def_delegator :@universe, :toggle_dialog_visibility, :toggle_dialog_layer
  def_delegators :@universe, :battle_layer, :npcs, :menu_layer,
    :reset_menu_positions, :add_notification, :toggle_bg_music, 
    :current_battle_participant_offset, :world_number, :notifications_layer, 
    :notifications, :current_selected_menu_entry_name, :current_menu_entries,
    :monsters


  #TODO the handler should be internal to event system, these should delegate there
  def_delegators :@event_handler, :make_magic_hooks, :make_magic_hooks_for, 
    :append_hook, :remove_hook, :handle
  def_delegators :@event_system, :non_menu_hooks, :rebuild_event_hooks
  def_delegator :@event_system, :menu_active_hooks, :menu_hooks
  def_delegator :@event_system, :battle_active_hooks, :battle_hooks
  def_delegator :@event_system, :non_menu_hooks, :non_battle_hooks

  def_delegator :@player, :update_tile_coords, :update_player_tile_coords
  def_delegator :@player, :set_position, :set_player_position
  def_delegator :@player, :get_position, :get_player_position
  def_delegators :@player, :party_members, :inventory_info, :inventory_at,
    :inventory, :use_weapon, :set_key_pressed_for, :inventory_count,
    :set_key_pressed_for_time, :player_missions, :mission_achieved?


  def current_battle
    battle_layer.battle
  end

  def toggle_battle_hooks(in_battle=false)
    EventManager.new.swap_event_sets(self, in_battle, non_battle_hooks, battle_hooks)
  end
  def toggle_menu
    EventManager.new.swap_event_sets(self, menu_layer.active?, non_menu_hooks, menu_hooks)
    menu_layer.toggle_activity
    unless menu_layer.active?
      menu_layer.reset_indices
    end
  end

  def interact_with_facing(event)
    @player.interact_with_facing(self)
  end

  def simulate_event_with_key(k)
    @event_system.queue << KeyPressedFacade.new(k) #TODO don't have references to the facades leak outside factories
  end

  private
  def menu_enter(event)
    menu_layer.enter_current_cursor_location(self)
  end
  def menu_right(event)
    menu_layer.enter_current_cursor_location(self)
  end
  def battle_up
    @universe.battle_layer.enter_current_cursor_location(self)
  end
  def battle_confirm
    battle_layer.enter_current_cursor_location(self)
  end
  def capture_ss(event)
    #TODO this does not work, find a different way to dump screen data
    #@screen.savebmp("screenshot.bmp")

    SDL.SaveBMP_RW("screenshot.bmp",@screen, 0)
  end

  def step

      fill_bg

      blit_universe
      fetch_events
      tick = tick_clock
      update_hud(tick)
      process_events

      blit_player
      blit_hud
      blit_game_layers

      refresh_screen

  end

  def fill_bg
    @screen.fill( :black )
  end
  def blit_universe
    @universe.blit_world(@screen, @player)
  end
  def fetch_events
    @event_system.queue.fetch_sdl_events
  end

  #TODO move this method into the event system 
  def tick_clock
    tick = @event_system.clock.tick
    @event_system.queue << tick
    tick
  end
  def update_hud(tick)
    @hud.update :time => "Framerate: #{1.0/tick.seconds}"
  end
  def process_events
    @event_system.queue.each do |event|
      handle( event ) #if !@paused
    end
  end
  def blit_player

    if @player.using_weapon?
      @player.draw_weapon(@screen)
    end
    @player.draw(@screen)
  end
  def blit_hud
    @hud.draw
  end
  def blit_game_layers
    @universe.draw_game_layers_if_active
  end
  def refresh_screen
    @screen.update()
  end

  

end
