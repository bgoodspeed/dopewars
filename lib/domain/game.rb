
class Game
  include Rubygame
  include Rubygame::Events
  include Rubygame::EventActions
  include Rubygame::EventTriggers

  include EventHandler::HasEventHandler

  attr_accessor :player, :universe, :screen
  def initialize()
    @factory = GameInternalsFactory.new
    @screen = @factory.make_screen
    @clock = @factory.make_clock
    @queue = @factory.make_queue
    world1 = @factory.make_world1
    world2 = @factory.make_world2
    world3 = @factory.make_world3
    @universe = @factory.make_universe([world1, world2, world3], @factory.make_game_layers(@screen, self), @factory.make_sound_effects, self) #XXX might be bad to pass self and make loops in the obj graph
#    @universe.toggle_bg_music #TODO turned this off because it was annoying me

    @player = @factory.make_player(@screen, @universe)
    world1.add_npc(@factory.make_npc(@player, @universe))
    world1.add_npc(@factory.make_monster(@player, @universe))
    @hud = @factory.make_hud(@screen, @player, @universe)
    always_on_hooks = {
      :escape => :quit,
      :q => :quit,
      QuitRequested => :quit,
      :c => :capture_ss,
      :d => :toggle_dialog_layer,
      :m => :toggle_menu,
      :p => :pause
    }
    menu_killed_hooks = { :i => :interact_with_facing, :space => :use_weapon, :p => :toggle_bg_music }
    menu_active_hooks = { :left => :menu_left, :right => :menu_right, :up => :menu_up, :down => :menu_down, :i => :menu_enter, :b => :menu_cancel }
    battle_hooks = {
      :left => :battle_left, :right => :battle_right, :up => :battle_up, :down => :battle_down,
      :i => :battle_confirm, :b => :battle_cancel
    }

    @event_helper = @factory.make_event_hooks(self, always_on_hooks, menu_killed_hooks, menu_active_hooks, battle_hooks)

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
  def battle_begun(universe, player)
    toggle_battle_hooks(false)
  end
  def battle_completed
    toggle_battle_hooks(true)
    @player.clear_keys
  end


  def start_battle(monster)
    battle_layer.start_battle(self, universe, player, monster)
  end

  def rebuild_hud
    @hud = @factory.make_hud(@screen, @player, @universe)
  end

  def all_hooks
    @event_handler.hooks.flatten
  end

  def remove_all_hooks
    puts "pre hook count: #{all_hooks.size}"
    all_hooks.each {|hook|
      remove_hook(hook)
    }
    puts "post hook count: #{all_hooks.size}"
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
    :notifications, :current_selected_menu_entry_name, :current_menu_entries

  def_delegators :@event_helper, :non_menu_hooks, :rebuild_event_hooks
  def_delegator :@event_helper, :menu_active_hooks, :menu_hooks
  def_delegator :@event_helper, :battle_active_hooks, :battle_hooks
  def_delegator :@event_helper, :non_menu_hooks, :non_battle_hooks

  def_delegator :@player, :update_tile_coords, :update_player_tile_coords
  def_delegator :@player, :set_position, :set_player_position
  def_delegator :@player, :get_position, :get_player_position
  def_delegators :@player, :party_members, :inventory_info, :inventory_at,
    :inventory, :use_weapon, :set_key_pressed_for, :inventory_count


  def toggle_battle_hooks(in_battle=false)
    EventManager.new.swap_event_sets(self, in_battle, non_battle_hooks, battle_hooks)
  end
  def toggle_menu
    #puts "tm: #{@event_helper.menu_active_hooks}"
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
    @queue << KeyPressed.new(k)
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
    @queue.fetch_sdl_events
  end
  def tick_clock
    tick = @clock.tick
    @queue << tick
    tick
  end
  def update_hud(tick)
    @hud.update :time => "Framerate: #{1.0/tick.seconds}"
  end
  def process_events
    @queue.each do |event|
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
