#!/bin/env ruby

# One way of making an object start and stop moving gradually:
# make user input affect acceleration, not velocity.

require 'rubygems'

require 'rubygame'
require 'json'
require 'forwardable'
require 'lib/font_loader'
require 'lib/topo_map'
require 'lib/hud'
require 'lib/inventory'
require 'lib/hero'



include Rubygame
include Rubygame::Events
include Rubygame::EventActions
include Rubygame::EventTriggers

@@SCREEN_X = 640
@@SCREEN_Y = 480
@@BGX = 1280
@@BGY = 960
@@MENU_LAYER_INSET = 25
@@MENU_TEXT_INSET = 10
@@NOTIFICATION_TEXT_INSET = 10
@@MENU_LINE_SPACING = 25
@@NOTIFICATION_LINE_SPACING = 25
@@MENU_TEXT_WIDTH = 100
@@LAYER_INSET = 25
@@TEXT_INSET = 10
@@HERO_START_BATTLE_PTS = 1000
@@HERO_BATTLE_PTS_RATE = 1.1
@@MONSTER_START_BATTLE_PTS = 800
@@MONSTER_BATTLE_PTS_RATE = 1.0
@@READINESS_POINTS_PER_SECOND = 1000
@@READINESS_POINTS_NEEDED_TO_ACT = 3000
@@DEFAULT_ACTION_COST = 2500
@@ATTACK_ACTION_COST = 2000
@@ITEM_ACTION_COST = 1500
@@NOOP_ACTION_COST = 1000

@@OPEN_TREASURE = 'O'
@@MONSTER_X = 32
@@MONSTER_Y = 32
@@NOTIFICATION_LAYER_WIDTH = @@SCREEN_X/3
@@NOTIFICATION_LAYER_HEIGHT = @@SCREEN_Y/3
@@NOTIFICATION_LAYER_INSET_X = 2 * @@SCREEN_X/3
@@NOTIFICATION_LAYER_INSET_Y = 2 * @@SCREEN_Y/3
@@TICKS_TO_DISPLAY_NOTIFICATIONS = 125
@@GAME_TITLE = "splatwars"

@@STATUS_WIDTH = 100
@@STATUS_HEIGHT = 300
@@MENU_DETAILS_INSET_X = 300
@@MENU_DETAILS_INSET_Y = 25
@@MENU_OPTIONS_INSET_X = 400
@@MENU_OPTIONS_INSET_Y = 25


@@BATTLE_INVENTORY_XC = 400
@@BATTLE_INVENTORY_XF = 0
@@BATTLE_INVENTORY_YC = 25
@@BATTLE_INVENTORY_YF = 25
module JsonHelper
  def self.included(kmod)
    kmod.class_eval <<-EOF
  def self.json_create(o)
    puts "json creating #{kmod}" ; new(*o['data'])
  end
    EOF
  end
  def to_json(*a)
    puts "to_json in #{self.class.name}"
    {
      'json_class' => self.class.name,
      'data' => json_params
    }.to_json(*a)
  end
end

class GameLayers
  extend Forwardable
  def_delegator :@menu_layer, :move_cursor_up, :menu_move_cursor_up
  def_delegator :@menu_layer, :move_cursor_down, :menu_move_cursor_down
  def_delegator :@menu_layer, :cancel_action, :menu_cancel_action
  def_delegator :@battle_layer, :move_cursor_up, :battle_move_cursor_up
  def_delegator :@battle_layer, :move_cursor_down, :battle_move_cursor_down
  def_delegator :@battle_layer, :cancel_action, :battle_cancel_action
  def_delegators :@notifications_layer, :add_notification
  def_delegators :@battle_layer, :current_battle_participant_offset



  attr_reader :dialog_layer, :menu_layer, :battle_layer, :notifications_layer
  def initialize(dialog_layer=nil, menu_layer=nil, battle_layer=nil, notif_layer=nil)
    @dialog_layer = dialog_layer
    @menu_layer = menu_layer
    @battle_layer = battle_layer
    @notifications_layer = notif_layer
  end

  def draw_game_layers_if_active
    if @dialog_layer.active?
      @dialog_layer.draw
    end
    if @menu_layer.active?
      @menu_layer.draw
    end
    if @battle_layer.active?
      @battle_layer.draw
    end
    if @notifications_layer.active?
      @notifications_layer.draw
    end
  end

  def reset_menu_positions
    @menu_layer.reset_indices
  end
end

class BackgroundMusic
  def initialize(filename)
    @filename = filename
    @music = Music.load(@filename)
  end

  def play_pause
    if @music.playing?
      @music.pause
    else
      @music.play
    end
  end
  def fade_out_bg_music
    @music.fade_out(2)
  end
  def fade_in_bg_music
    @music.play({:fade_in => 2})
  end
end

class SoundEffect
  WEAPON = "weapon"
  WARP = "warp"
  BATTLE_START = "battle"
  TREASURE = "treasure"
end

class SoundEffectSet
  def initialize(filenames)
    @effects = {}
    filenames.each do |filename|
      @effects[filename] = Sound.load(filename)
    end
  end

  def mapping
    pal = {}
    pal[SoundEffect::TREASURE] = "treasure-open.ogg"
    pal[SoundEffect::WEAPON] = "laser.ogg"
    pal[SoundEffect::WARP] = "warp.ogg"
    pal[SoundEffect::BATTLE_START] = "battle-start.ogg"
    pal
  end

  def play_sound_effect(which)
    @effects[mapping[which]].play
  end
end
class Universe
  attr_reader :worlds, :current_world,  :current_world_idx, :game_layers, :sound_effects, :game

  extend Forwardable
  def_delegators :@sound_effects, :play_sound_effect
  def_delegators :@current_world, :interpret, :npcs, :blit_world, :toggle_bg_music, :fade_out_bg_music, :fade_in_bg_music
  def_delegators :@game_layers, :dialog_layer, :menu_layer, :battle_layer, :notifications_layer, 
    :draw_game_layers_if_active, :menu_move_cursor_up, :menu_move_cursor_down, :menu_cancel_action,
    :battle_cancel_action, :battle_move_cursor_down, :battle_move_cursor_up, :add_notification,
    :reset_menu_positions, :current_battle_participant_offset

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
    set_current_world(world_by_index(idx))
  end

  def reblit_backgrounds
    @worlds.each {|world| world.reblit_background}
  end
  def replace_world_pallettes(orig_uni)
    worlds_with_index(orig_uni) {|world, orig_world|
      world.replace_pallettes(orig_world)
    }
  end

  def worlds_with_index(orig_uni)
    @worlds.each_with_index do |world, index|
      orig_world = orig_uni.world_by_index(index)
      yield world, orig_world
    end
  end
  def replace_world_bgsurfaces(orig_uni)
    worlds_with_index(orig_uni) {|world, orig_world|
      world.replace_bgsurface(orig_world)
    }
  end

  def replace_world_bgmusics(orig_uni)
    worlds_with_index(orig_uni) {|world, orig_world|
      world.replace_bgmusic(orig_world)
    }

  end

  include JsonHelper
  def json_params
    [ @current_world_idx, @worlds]
  end
end

class WorldState
  attr_reader :topo_interpreter, :interaction_interpreter,:npcs, :background_surface, :background_music
            
  extend Forwardable
  def_delegator :@topo_interpreter, :update, :update_topo_map
  def_delegator :@topo_interpreter, :update, :update_topo_map
  def_delegator :@topo_interpreter, :can_walk_at?, :can_walk_on_background_at?
  def_delegator :@interaction_interpreter, :x_offset_for_world, :x_offset_for_interaction
  def_delegator :@interaction_interpreter, :y_offset_for_world, :y_offset_for_interaction
  def_delegator :@interaction_interpreter, :update, :update_interaction_map
  def_delegators :@topo_interpreter, :x_offset_for_world, :y_offset_for_world
  def_delegators :@interaction_interpreter, :blit_foreground
  def_delegator :@background_music, :play_pause, :toggle_bg_music
  def_delegators :@background_music, :fade_out_bg_music, :fade_in_bg_music

  def initialize(topointerp, interinterp, npcs, bgsurface, bgmusic)
    @topo_interpreter = topointerp
    @interaction_interpreter = interinterp
    @npcs = npcs
    @background_surface = bgsurface
    @background_music = bgmusic
    
    reblit_background unless bgsurface.nil?
  end

  def replace_pallettes(orig_world)
    @topo_interpreter = orig_world.topo_interpreter
    @interaction_interpreter.replace_pallette(orig_world.interaction_interpreter)
  end

  def reblit_background
    @topo_interpreter.blit_to(@background_surface)
  end

  def delete_monster(monster)
    @npcs -= [monster]
  end
  def add_npc(npc)
    @npcs += [npc]
  end

  def blit_world(screen, player)
    sx = screen.w
    sy = screen.h
    ext_x = sx/2
    ext_y = sy/2
    screen_left = player.px - ext_x
    screen_top = player.py - ext_y

    @background_surface.blit(screen, [0,0], [ screen_left,screen_top, sx, sy])
    blit_foreground(screen, player.px, player.py)

    @npcs.each {|npc|
      npc.draw(screen, player.px, player.py, sx, sy) if npc.nearby?(player.px, player.py, ext_x, ext_y)
    }
  end


  def replace_bgsurface(orig_world)
    @background_surface = orig_world.background_surface
  end
  def replace_bgmusic(orig_world)
    @background_music = orig_world.background_music
  end

  

  include JsonHelper
  def json_params
    [ nil, @interaction_interpreter, @npcs, nil,nil]
  end
end

class KeyHolder
  def initialize
    @keys = []
  end

  extend Forwardable
  def_delegators :@keys, :include?, :empty?

  def delete_key(key)
    @keys -= [key]
  end
  def add_key(key)
    @keys += [key]
  end

  def clear_keys
    @keys.clear
  end
end
class AlwaysDownMonsterKeyHolder < KeyHolder
  @@DOWNKEY = :always_down
  def initialize(key=@@DOWNKEY)
    super()
    add_key(key)
  end

  def switch(oldkey, newkey)
    delete_key(oldkey)
    add_key(newkey)
  end
end

class AnimationHelper
  @@FRAME_SWITCH_THRESHOLD = 0.40
  @@ANIMATION_FRAMES = 4

  def current_frame
    @animation_frame
  end

  def initialize(key_holder, animation_frames=@@ANIMATION_FRAMES)
    @key_holder = key_holder
    @animation_counter = 0
    @animation_frame = 0
    @animation_frames = animation_frames
  end
  def update_animation(dt)
    @animation_counter += dt
    if @animation_counter > @@FRAME_SWITCH_THRESHOLD
      @animation_counter = 0
      unless @key_holder.empty?
        @animation_frame = (@animation_frame + 1) % @animation_frames
        yield @animation_frame
      end
    end

  end
  
end
class InteractionHelper
  @@INTERACTION_DISTANCE_THRESHOLD = 80 #XXX tweak this, currently set to 1/2 a tile

  attr_accessor :facing
  def initialize(player, universe)
    @player = player
    @universe = universe
    @facing = :down
  end

  def interact_with_facing(game, px,py)
    if @universe.dialog_layer.active
      puts "confirming/closing/paging dialog"
      @universe.dialog_layer.toggle_activity
      return #XXX check this return policy (ie currently first matching action is the only one run
    end

    puts "you are facing #{@facing}"
    tilex = @universe.current_world.x_offset_for_interaction(px)
    tiley = @universe.current_world.y_offset_for_interaction(py)
    this_tile_interacts = @universe.current_world.interaction_interpreter.interpret(tilex, tiley)
    facing_tile_interacts = false

    if this_tile_interacts
      puts "you can interact with the current tile"
      this_tile_interacts.activate(game, @player, @universe.current_world, tilex, tiley)
      return
    end

    if @facing == :down
      facing_tilex = tilex
      facing_tiley = tiley + 1
      facing_tile_dist = (@universe.current_world.interaction_interpreter.top_side(tiley + 1) - py).abs
    end
    if @facing == :up
      facing_tilex = tilex
      facing_tiley = tiley - 1
      facing_tile_dist = (@universe.current_world.interaction_interpreter.bottom_side(tiley - 1) - py).abs
    end
    if @facing == :left
      facing_tilex = tilex - 1
      facing_tiley = tiley
      facing_tile_dist = (@universe.current_world.interaction_interpreter.right_side(tilex - 1) - px).abs
    end
    if @facing == :right
      facing_tilex = tilex + 1
      facing_tiley = tiley
      facing_tile_dist = (@universe.current_world.interaction_interpreter.left_side(tilex + 1) - px).abs
    end

    facing_tile_interacts = @universe.current_world.interaction_interpreter.interpret(facing_tilex, facing_tiley)
    facing_tile_close_enough = facing_tile_dist < @@INTERACTION_DISTANCE_THRESHOLD

    if facing_tile_close_enough and facing_tile_interacts
      puts "you can interact with the facing tile in the #{@facing} direction, it is at #{facing_tilex} #{facing_tiley}"
      facing_tile_interacts.activate(game,@player, @universe.current_world, facing_tilex, facing_tiley) #@interactionmap, facing_tilex, facing_tiley, @bgsurface, @topomap, @topo_pallette
      return
    end

    interactable_npcs = @universe.current_world.npcs.select {|npc| npc.nearby?(px,py, @@INTERACTION_DISTANCE_THRESHOLD, @@INTERACTION_DISTANCE_THRESHOLD)  }
    unless interactable_npcs.empty?
      puts "you can interact with the npc: #{interactable_npcs[0]}"
      npc = interactable_npcs[0] #TODO what if there are multiple npcs to interact w/? one at a time? all of them?
      npc.interact(game, @universe, @player)
    end

  end
end

class TileCoordinateSet
  attr_reader :minx, :maxx, :miny, :maxy
  def initialize(minx, maxx, miny, maxy)
    @minx = minx
    @maxx = maxx
    @miny = miny
    @maxy = maxy
  end
end

class CoordinateHelper
  attr_accessor :px, :py

  def initialize(px,py, key,universe, hero_x_dim, hero_y_dim, max_speed=400, accel=1200, slowdown=800)
    @hero_x_dim, @hero_y_dim =  hero_x_dim, hero_y_dim
    @universe = universe
    @keys = key
    @px, @py = px, py # Current Position
    @vx, @vy = 0, 0 # Current Velocity
    @ax, @ay = 0, 0 # Current Acceleration
    @max_speed = max_speed # Max speed on an axis
    @accel = accel # Max Acceleration on an axis
    @slowdown = slowdown # Deceleration when not accelerating
    update_tile_coords
  end

  def world_coords
    TileCoordinateSet.new( @universe.current_world.x_offset_for_world(base_x),
      @universe.current_world.x_offset_for_world(max_x),
      @universe.current_world.y_offset_for_world(base_y ),
      @universe.current_world.y_offset_for_world(max_y) )
  end

  def interact_coords
    TileCoordinateSet.new( @universe.current_world.x_offset_for_interaction(base_x),
      @universe.current_world.x_offset_for_interaction(max_x),
      @universe.current_world.y_offset_for_interaction(base_y ),
      @universe.current_world.y_offset_for_interaction(max_y) )
  end

  def max_x
    @px 
  end
  def max_y
    @py 
  end

  def base_x
    @px -  @hero_x_dim
  end
  
  def base_y
    @py -  @hero_y_dim
  end
 def collides_on_x?(x)
    (@px - x).abs < x_ext
  end
  def collides_on_y?(y)
    (@py - y).abs < y_ext
  end


  def update_tile_coords
    @bg_tile_coords = world_coords
    @interaction_tile_coords = interact_coords
  end
  def update_accel
    x, y = 0,0

    x -= 1 if @keys.include?( :left )
    x += 1 if @keys.include?( :right )
    y -= 1 if @keys.include?( :up ) # up is down in screen coordinates
    y += 1 if @keys.include?( :down )

    # Scale to the acceleration rate. This is a bit unrealistic, since
    # it doesn't consider magnitude of x and y combined (diagonal).
    x *= @accel
    y *= @accel

    @ax, @ay = x, y
  end
  def update_vel( dt )
    @vx = update_vel_axis( @vx, @ax, dt )
    @vy = update_vel_axis( @vy, @ay, dt )
  end
  def update_vel_axis( v, a, dt )

    # Apply slowdown if not accelerating.
    if a == 0
      if v > 0
        v -= @slowdown * dt
        v = 0 if v < 0
      elsif v < 0
        v += @slowdown * dt
        v = 0 if v > 0
      end
    end

    # Apply acceleration
    v += a * dt

    # Clamp speed so it doesn't go too fast.
    v = @max_speed if v > @max_speed
    v = -@max_speed if v < -@max_speed

    return v
  end
  def x_ext
    @hero_x_dim/2
  end
  def y_ext
    @hero_y_dim/2
  end
  def clamp_to_world_dimensions
    minx = @px - x_ext
    maxx = @px + x_ext
    miny = @py - y_ext
    maxy = @py + y_ext
    @px = x_ext if minx < 0
    @px = @@BGX - x_ext if maxx > @@BGX #TODO this should come from the current world

    @py = y_ext if miny < 0
    @py = @@BGY - y_ext if maxy > @@BGY
  end
  def check_corners(interp, x1, y1, x2, y2)
    c1 = interp.can_walk_at?(x1,y1)
    c2 = interp.can_walk_at?(x2,y2)

    unless c1 and c2
      return true
    end
    false
  end
  def clamp_to_tile_restrictions_on_y(interp, new_bg_tile_coords)
    rv = false

    if new_bg_tile_coords.miny != @bg_tile_coords.miny
      rv = true if check_corners(interp, new_bg_tile_coords.maxx, new_bg_tile_coords.miny, new_bg_tile_coords.minx, new_bg_tile_coords.miny)
    end
    if new_bg_tile_coords.maxy != @bg_tile_coords.maxy
      rv = true if check_corners(interp, new_bg_tile_coords.maxx, new_bg_tile_coords.maxy, new_bg_tile_coords.minx, new_bg_tile_coords.maxy)
    end
    rv
  end
  def clamp_to_tile_restrictions_on_x(interp, new_bg_tile_coords)
    rv = false
    
    if new_bg_tile_coords.minx != @bg_tile_coords.minx
      rv = true if check_corners(interp, new_bg_tile_coords.minx, new_bg_tile_coords.miny, new_bg_tile_coords.minx, new_bg_tile_coords.maxy)
    end

    if new_bg_tile_coords.maxx != @bg_tile_coords.maxx
      rv = true if check_corners(interp, new_bg_tile_coords.maxx, new_bg_tile_coords.miny, new_bg_tile_coords.maxx, new_bg_tile_coords.maxy)
    end

    rv
  end
  def blocking(col)
    col.select do |npc|
      npc.is_blocking?
    end
  end
  def x_hits(npcs)
    npcs.select do |npc|
      npc.collides_on_x?(base_x) or npc.collides_on_x?(max_x)
    end
  end
  def y_hits(npcs)
    npcs.select do |npc|
      npc.collides_on_y?(base_y) or npc.collides_on_y?(max_y)
    end
  end
  def hit_blocking_npcs_on_x(npcs)
    blocking(y_hits(x_hits(npcs)))
  end
  def hit_blocking_npcs_on_y(npcs)
    blocking(y_hits(x_hits(npcs)))
  end


  def candidate_npcs(who=nil)
    @universe.current_world.npcs
  end

  def update_pos( dt, who=nil )
    dx = @vx * dt
    dy = @vy * dt

    @px += dx
    x_collisions = hit_blocking_npcs_on_x(candidate_npcs(who))
    @py += dy
    y_collisions = hit_blocking_npcs_on_x(candidate_npcs(who)) - x_collisions
    clamp_to_world_dimensions

    topo = @universe.current_world.topo_interpreter
    interact = @universe.current_world.interaction_interpreter
    new_bg_tile_coords = world_coords
    new_interaction_tile_coords = interact_coords

    @px -= dx if clamp_to_tile_restrictions_on_x(topo, new_bg_tile_coords) or clamp_to_tile_restrictions_on_x(interact, new_interaction_tile_coords) or !x_collisions.empty?
    @py -= dy if clamp_to_tile_restrictions_on_y(topo, new_bg_tile_coords) or clamp_to_tile_restrictions_on_y(interact, new_interaction_tile_coords) or !y_collisions.empty?

#    puts "tile topo x: #{clamp_to_tile_restrictions_on_x(topo, new_bg_tile_coords)} tile interact x: #{clamp_to_tile_restrictions_on_x(interact, new_interaction_tile_coords)} x cols: #{!x_collisions.empty?}"
#    puts "tile topo y: #{clamp_to_tile_restrictions_on_y(topo, new_bg_tile_coords)} tile interact y: #{clamp_to_tile_restrictions_on_y(interact, new_interaction_tile_coords)} y cols: #{!y_collisions.empty?}"
    cols = y_hits(x_hits(candidate_npcs(who)))
    handle_collision(cols) unless cols.empty?
    update_tile_coords
  end

  def handle_collision(cols)
    monsters = cols.select { |col| col.class == Monster}
    return if monsters.empty?
    monster = monsters[0]
    monster.interact(@universe.game, @universe, @universe.game.player)
  end
end

class MonsterCoordinateHelper < CoordinateHelper
  def candidate_npcs(who=nil)
    r = super()
    cands = (r - [who]) # + [who.player]
    
    cands
  end
  def handle_collision(cols)
    #NOOP
  end
end

module ColorKeyHelper

  def set_colorkey_from_corner(s)
    s.colorkey = s.get_at(0,0)
  end
end

class AnimatedSpriteHelper
  attr_reader :image, :rect, :px, :py
  include ColorKeyHelper
  def initialize(filename, px, py, avatar_x_dim, avatar_y_dim)
    @all_char_postures = Surface.load(filename)

    set_colorkey_from_corner(@all_char_postures)
    @all_char_postures.alpha = 255

    @px = px
    @py = py #XXX this might be a bug to use these, they should come from the coord helper?
    @avatar_x_dim = avatar_x_dim
    @avatar_y_dim = avatar_y_dim


    @image = Surface.new([@avatar_x_dim,@avatar_y_dim])
    @image.fill(@all_char_postures.colorkey)
    @image.colorkey = @all_char_postures.colorkey
    @image.alpha = 255
    @all_char_postures.blit(@image, [0,0], Rect.new(0,0,@avatar_x_dim,@avatar_y_dim))

    @rect = @image.make_rect
    @rect.center = [px, py]

    set_frame(0)
  end


  def set_frame(last_dir=0)
    @last_direction_offset = last_dir
  end

  def replace_avatar(animation_frame)
    @image.fill(@all_char_postures.colorkey)
    @all_char_postures.blit(@image, [0,0], Rect.new(animation_frame * @avatar_x_dim, @last_direction_offset,@avatar_x_dim, @avatar_y_dim))
  end

 
end
class TextRenderingHelper
  def initialize(layer, font)
    @layer = layer
    @font = font
  end
  def render_lines_to_layer(text_lines, conf)
    render_lines_to(@layer, text_lines, conf)
  end

  def render_lines_to(layer, text_lines, conf)
    text_lines.each_with_index do |text, index|
      text_surface = @font.render text.to_s, true, [16,222,16]
      text_surface.blit layer, [conf.xc + conf.xf * index,conf.yc + conf.yf * index]
    end
  end

end

#TODO this class should be broken up
class MenuHelper
  def initialize(screen, layer,text_helper, sections, cursor_x, cursor_y, cursor_main_color=:blue, cursor_inactive_color=:white)
    @layer = layer
    @text_rendering_helper = text_helper
    @cursor = Surface.new([cursor_x, cursor_y])
    @cursor_main_color = cursor_main_color
    @cursor_inactive_color = cursor_inactive_color
    @cursor.fill(@cursor_inactive_color)
    @screen = screen
    reset_indices
    replace_sections(sections)
  end

  def color_for_current_section_cursor
    @cursor_main_color
  end

  def active_section
    @menu_sections[@cursor_position]
  end

  def move_cursor_down
    move_cursor(1)
  end

  def clamping_delta(value, maxsize, delta=1)
    (value + delta) % maxsize
  end

  def size_or_one(target)
    target.size
    #target.respond_to?(:size) ? target.size : 1
  end

  def move_cursor(dir)
    if @show_section
       if subsection_active?(@section_position)
         if @needs_option
           puts "moving at option layer: #{@option_position} of #{size_or_one(active_option)}"
           @option_position = clamping_delta(@option_position, size_or_one(active_option), dir)
         else
           puts "moving at subsection layer"
          @subsection_position = clamping_delta(@subsection_position, size_or_one(active_subsection), dir)
         end
      else
        puts "moving at section layer"
        @section_position = clamping_delta(@section_position, size_or_one(active_section.content), dir)
       end
    else
      puts "moving at top layer"
      @cursor_position = clamping_delta(@cursor_position, size_or_one(@text_lines), dir)
    end
  end

  def move_cursor_up
    move_cursor(-1)
  end
  def enter_current_cursor_location(game)
    if @show_section
      if subsection_active?(@section_position)
        if @needs_option
          puts "activating at option layer"
          active_subsection.activate(@cursor_position, game, @section_position, @subsection_position, @option_position)
        else
          puts "activating at subsection layer"
          @needs_option = active_subsection.activate(@cursor_position, game, @section_position, @subsection_position)
        end
        
      else
        puts "activating at section layer"
        active_subsection.activate(@cursor_position, game, @section_position)
      end
      
    else
      puts "showing section in lieu of activation at top layer"
      @show_section = true
    end

  end
  def cancel_action
    if @needs_option
      @needs_option = false
    end
    if subsection_active?(@section_position)
      @active_position = nil
      return
    end
    if @show_section
      @show_section = false
      @section_position = 0
      return
    end

    reset_indices
  end
  def replace_sections(sections)
    @menu_sections = sections
    @text_lines = @menu_sections.collect{|ms|ms.text}
  end
  #TODO this is odd to have in the api for this class... reconsider
  def render_text_to_layer(text, conf)
    @text_rendering_helper.render_lines_to_layer( text, conf)
  end
  def render_text_to(surface, text, conf)
    @text_rendering_helper.render_lines_to(surface, text, conf)
  end
  def active_subsection
    active_section.content_at(@section_position)
  end
  def active_option
    active_subsection.option_at(@option_position)
  end

  def draw(menu_layer_config, game)
    render_text_to_layer( @text_lines, menu_layer_config.main_menu_text)
    @cursor.fill(color_for_current_section_cursor)
    if @show_section
      render_text_to_layer(active_section.text_contents, menu_layer_config.section_menu_text)
      conf = menu_layer_config.in_section_cursor
      
      if subsection_active?(@section_position)
        surf = active_subsection.details
        conf = menu_layer_config.in_subsection_cursor

        surf.blit(@layer, menu_layer_config.details_inset_on_layer) if surf
        @cursor.fill(:black)
        
        if @needs_option
          conf = menu_layer_config.in_option_section_cursor
          optsurf = active_subsection.surface_for(@subsection_position)
          optsurf.blit(@layer, menu_layer_config.options_inset_on_layer) if optsurf
          @cursor.blit(@layer, conf.cursor_offsets_at(@option_position, game, active_subsection))
        else
          @cursor.blit(@layer, conf.cursor_offsets_at(@subsection_position, game, active_subsection))
        end
      else
        @cursor.blit(@layer, conf.cursor_offsets_at(@section_position, game, active_subsection))
      end
    else

      conf = menu_layer_config.main_cursor
#      puts "top level: #{active_section}"
      @cursor.blit(@layer, conf.cursor_offsets_at(@cursor_position, game, active_section))
    end
    @layer.blit(@screen, menu_layer_config.layer_inset_on_screen)
  end

  def subsection_active?(position)
    (@active_position == position) && !@active_position.nil?
  end
  def set_active_subsection(position)
    puts "activated with #{position}"
    @active_position = position
  end

  def reset_indices
    @active_position = nil
    @cursor_position = 0
    @section_position = 0
    @option_position = 0
    @subsection_position = 0
    @show_section = false
    @needs_option = false
  end
end
class BattleMenuHelper < MenuHelper
  def initialize(battle, screen, layer,text_helper, sections, cursor_x, cursor_y, cursor_main_color=:blue, cursor_inactive_color=:white)
    super(screen, layer,text_helper, sections, cursor_x, cursor_y, cursor_main_color, cursor_inactive_color)
    @battle = battle
  end

  def current_cursor_member_ready?
    @battle.party.members[@cursor_position].ready?
  end

  def color_for_current_section_cursor
    if current_cursor_member_ready?
      @cursor_main_color
    else
      @cursor_inactive_color
    end
  end
  def enter_current_cursor_location(game)
    super(game) if current_cursor_member_ready?
  end


end

class Party
  extend Forwardable
  def_delegators :@inventory, :add_item, :gain_inventory, :inventory_info, :inventory_item_at
  def_delegators :leader, :world_weapon
  attr_reader :members, :inventory
  def initialize(members, inventory)
    @members = members
    @inventory = inventory
  end

  def collect
    @members.collect {|member| yield member}
  end

  def leader
    @members.first
  end
  def add_readiness(pts)
    @members.each {|member| member.add_readiness(pts) }
  end
  def gain_experience(pts)
    @members.each {|member| member.gain_experience(pts) }
  end

  def dead?
    living_members = @members.select {|m| !m.dead?}
    living_members.empty?
  end

  include JsonHelper
  def json_params
    [ @members, @inventory]
  end
end

class WorldWeapon
  
  attr_reader :ticks
  def initialize(pallette, max_ticks=25)
    @pallette = pallette
    @ticks = 0
    @max_ticks = max_ticks
  end
  def displayed
    @ticks += 1
  end

  def die
    @ticks = 0
  end
  def fired_from(px, py,facing)
    @startx = px
    @starty = py
    @facing = facing
  end

  def consumption_ratio
    @ticks.to_f/@max_ticks.to_f
  end

  def consumed?
    @ticks >= @max_ticks
  end

  def draw_weapon(screen)
    puts "starting at #{@startx},#{@starty} pointing #{@facing} "
    puts "draw the weapon animation based on #{@ticks}"
  end
end

class SwungWorldWeapon < WorldWeapon
  include ColorKeyHelper

  @@WEAPON_UP_OFFSET_X = -15
  @@WEAPON_UP_OFFSET_Y = -45
  @@WEAPON_DOWN_OFFSET_X = -15
  @@WEAPON_DOWN_OFFSET_Y = 20
  @@WEAPON_LEFT_OFFSET_X = -45
  @@WEAPON_LEFT_OFFSET_Y = -15
  @@WEAPON_RIGHT_OFFSET_X = 0
  @@WEAPON_RIGHT_OFFSET_Y = -10
  @@WEAPON_UP_ANGLE = 270
  @@WEAPON_DOWN_ANGLE = 120
  @@WEAPON_LEFT_ANGLE = -10
  @@WEAPON_RIGHT_ANGLE = 180
  @@WEAPON_ROTATION = 90

  def screen_config
    c = {}
    c[:up] = { :screen => [@@WEAPON_UP_OFFSET_X, @@WEAPON_UP_OFFSET_Y], :rotate => @@WEAPON_UP_ANGLE}
    c[:down] = { :screen => [@@WEAPON_DOWN_OFFSET_X, @@WEAPON_DOWN_OFFSET_Y], :rotate => @@WEAPON_DOWN_ANGLE}
    c[:left] = { :screen => [@@WEAPON_LEFT_OFFSET_X, @@WEAPON_LEFT_OFFSET_Y], :rotate => @@WEAPON_LEFT_ANGLE}
    c[:right] = { :screen => [@@WEAPON_RIGHT_OFFSET_X, @@WEAPON_RIGHT_OFFSET_Y], :rotate => @@WEAPON_RIGHT_ANGLE}
    c
  end

  def screen_offsets_for(facing)
    screen_config[facing][:screen]
  end

  def base_screen_offsets(screen)
    [screen.w/2, screen.h/2]
  end

  def effective_offsets(screen, facing)
    rv = base_screen_offsets(screen)
    so = screen_offsets_for(facing)
    rv[0] += so[0]
    rv[1] += so[1]
    rv
  end
  def starting_angle_for_facing(facing)
    screen_config[facing][:rotate]
  end
  def draw_weapon(screen)
    surf = @pallette['E'].surface
    surface = surf.rotozoom(consumption_ratio * @@WEAPON_ROTATION + starting_angle_for_facing(@facing), 1)
    set_colorkey_from_corner(surface)
    puts "surface: #{surface}"

    offs = effective_offsets(screen, @facing)
    surface.blit(screen,[ offs[0], offs[1], surface.w, surface.h])

    puts "starting at #{@startx},#{@starty} pointing #{@facing} "
    puts "draw the weapon animation based on #{@ticks}"
  end

end

class ShotWorldWeapon < WorldWeapon
end


class WorldWeaponHelper

  extend Forwardable
  def_delegators :@weapon, :draw_weapon

  def initialize(player)
    @player = player
    @weapon = nil
  end

  def use_weapon
    if using_weapon?
      puts "world weapon already in use!"
    else
      @weapon = @player.world_weapon
      @weapon.fired_from(@player.px, @player.py, @player.facing)
    end
  end

  def using_weapon?
    !@weapon.nil?
  end

  def update_weapon_if_active()
    return unless using_weapon?
    @weapon.displayed
    if @weapon.consumed?
      @weapon.die
      @weapon = nil
    end
  end


end

class Player
  include Sprites::Sprite
  include EventHandler::HasEventHandler
  
  attr_accessor :universe, :party

  extend Forwardable
  
  def_delegators :@interaction_helper, :facing
  def_delegators :@animated_sprite_helper, :image, :rect
  def_delegators :@coordinate_helper, :update_tile_coords, :px, :py
  def_delegators :@weapon_helper, :use_weapon, :using_weapon?, :draw_weapon
  def_delegators :@party, :add_readiness, :gain_experience, :gain_inventory, 
    :inventory, :dead?, :inventory_info, :inventory_item_at, :world_weapon
  def_delegators :@keys, :clear_keys
  def_delegator :@party, :add_item, :add_inventory
  def_delegator :@party, :members, :party_members

  attr_reader :filename, :hero_x_dim, :hero_y_dim
  def initialize( px, py,  universe, party, filename, hx, hy, sx, sy)
    @universe = universe
    @filename = filename
    @hero_x_dim = hx
    @hero_y_dim = hy
    @interaction_helper = InteractionHelper.new(self, @universe)
    @keys = KeyHolder.new
    @coordinate_helper = CoordinateHelper.new(px, py, @keys, @universe, @hero_x_dim, @hero_y_dim)
    @animation_helper = AnimationHelper.new(@keys)
    @weapon_helper = WorldWeaponHelper.new(self)
    @animated_sprite_helper = AnimatedSpriteHelper.new(filename, sx, sy, @hero_x_dim, @hero_y_dim)
    @party = party

    make_magic_hooks(
      KeyPressed => :key_pressed,
      KeyReleased => :key_released,
      ClockTicked => :update
    )
  end



  def interact_with_facing(game)
    @interaction_helper.interact_with_facing( game, @coordinate_helper.px , @coordinate_helper.py)
  end
  def set_position(px, py)
    @coordinate_helper.px = px
    @coordinate_helper.py = py
  end
  include JsonHelper
  def json_params
    [ @coordinate_helper.px, @coordinate_helper.py, @universe, @party, @filename,@hero_x_dim, @hero_y_dim, @animated_sprite_helper.px, @animated_sprite_helper.py]
  end

  private

  def key_pressed( event )
    newkey = event.key
    if [:down, :left,:up, :right].include?(newkey)
      @interaction_helper.facing = newkey
    end
    
    if event.key == :down
      @animated_sprite_helper.set_frame(0)
    elsif event.key == :left
      @animated_sprite_helper.set_frame(@hero_y_dim)
    elsif event.key == :right
      @animated_sprite_helper.set_frame(2 * @hero_y_dim)
    elsif event.key == :up
      @animated_sprite_helper.set_frame(3 * @hero_y_dim)
    end
    @animated_sprite_helper.replace_avatar(@animation_helper.current_frame)

    @keys.add_key(event.key)
  end

  def key_released( event )
    @keys.delete_key(event.key)
  end

  def update( event )
    dt = event.seconds # Time since last update
    @animation_helper.update_animation(dt) { |frame| @animated_sprite_helper.replace_avatar(frame) }
    @coordinate_helper.update_accel
    @coordinate_helper.update_vel( dt )
    @coordinate_helper.update_pos( dt )
    @weapon_helper.update_weapon_if_active
  end

  def x_ext
    @hero_x_dim/2
  end
  def y_ext
    @hero_y_dim/2
  end

end

class Treasure
  attr_accessor :name
  def is_blocking?
    true
  end
  def initialize(name)
    @name = name
  end

  def activate(game, player, worldstate, tilex, tiley)
    player.universe.play_sound_effect(SoundEffect::TREASURE)
    worldstate.update_interaction_map(tilex, tiley, @@OPEN_TREASURE)
    player.add_inventory(1, @name)
    game.add_notification(WorldScreenNotification.new("Got #{@name}"))
  end

  include JsonHelper
  def json_params
    [ @name]
  end
end
class OpenTreasure < Treasure
  def activate(game,  player, worldstate, tilex, tiley)
    puts "Nothing to do, already opened"
  end
end

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
    puts "player was at #{player.px},#{player.py}"
    player.set_position(@destination_x, @destination_y)
    puts "warp from  #{worldstate} to #{uni.world_by_index(@destination)}"
    uni.set_current_world_by_index(@destination)
    player.universe.fade_in_bg_music
  end
  include JsonHelper
  def json_params
    [ @destination]
  end
end

class Notification
  attr_reader :message, :time_to_live, :location
  def initialize(msg, ttl, location)
    @message = msg
    @time_to_live = ttl
    @location = location
  end

  def displayed
    @time_to_live -= 1
  end

  def dead?
    @time_to_live <= 0
  end
end

class WorldScreenNotification < Notification
  def initialize(msg)
    super(msg,@@TICKS_TO_DISPLAY_NOTIFICATIONS, [@@NOTIFICATION_LAYER_INSET_X,@@NOTIFICATION_LAYER_INSET_Y ])
  end
end
class BattleScreenNotification < Notification
  def initialize(msg)
    super(msg,@@TICKS_TO_DISPLAY_NOTIFICATIONS, [@@NOTIFICATION_LAYER_INSET_X,@@NOTIFICATION_LAYER_INSET_Y/3 ])
  end
end


class BattleHud
  def initialize(screen, text_rendering_helper, layer)
    @screen = screen
    @text_rendering_helper = text_rendering_helper
    @layer = layer

  end

  def map_to_colors(rate)
    r = rate.to_i
    1.upto(10).collect {|i| i <= r ? :blue : :red }
  end

  def draw(menu_layer_config, game, battle)
    heroes = battle.heroes
    health_rates = heroes.collect {|h| h.hp_ratio * 10}
    ready_rates = heroes.collect {|h| h.ready_ratio * 10}

    s = Surface.new([500, 50])
    s.fill(:green)

    health_rates.each_with_index do |hr, hi|
      sub = Surface.new([10, 10])
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

class AbstractActorAction
  extend Forwardable
  def initialize(actor, menu_helper)
    @actor = actor
    @menu_helper = menu_helper
  end
  def text
    @actor.name
  end

end

class UpdateEquipmentAction < AbstractActorAction

  def initialize(actor, menu_helper, game)
    super(actor, menu_helper)
    @game = game
  end

  def activate(cursor_position, game, section_position, subsection_position=nil, option_position=nil)
    @menu_helper.set_active_subsection(section_position)
    unless option_position.nil?
      new_gear = inventory[option_position]
      
      @actor.equip_in_slot_index(subsection_position, new_gear)
    end
    true
  end

  def option_at(idx)
    inventory
  end

  def equipment
    @actor.equipment_info
  end
  def details
    info_lines = equipment
    s = Surface.new([@@STATUS_WIDTH, @@STATUS_HEIGHT])
    s.fill(:yellow)
    @menu_helper.render_text_to(s, info_lines, TextRenderingConfig.new(0, 0, 0,@@MENU_LINE_SPACING))
    s
  end

  def inventory
    @game.inventory.inventory_info
  end

  def surface_for(posn)
    info_lines = inventory.collect {|i| i.to_info}
    s = Surface.new([@@STATUS_WIDTH, @@STATUS_HEIGHT])
    s.fill(:yellow)
    @menu_helper.render_text_to(s, info_lines, TextRenderingConfig.new(0, 0, 0,@@MENU_LINE_SPACING))
    s
  end

  def size
    @actor.equipment_info.size
  end


end


class LevelUpAction < AbstractActorAction

  def size
    2 #TODO this should come from the size of the attribute set
  end


  def details
    info_lines = @actor.status_info
    s = Surface.new([@@STATUS_WIDTH, @@STATUS_HEIGHT])
    s.fill(:green)
    @menu_helper.render_text_to(s, info_lines, TextRenderingConfig.new(0, 0, 0,@@MENU_LINE_SPACING))
    s
  end

  def activate(cursor_position, game, section_position, subsection_position=nil, option_position=nil)
    @menu_helper.set_active_subsection(section_position)
    if !subsection_position.nil?
      @actor.consume_level_up(subsection_position)
    end
    false
  end


end
class StatusDisplayAction< AbstractActorAction
  def size
    1
  end


  def activate(cursor_position, game, section_position, subsection_position=nil, option_position=nil)
    @menu_helper.set_active_subsection(section_position)
    false
  end


  def details
    info_lines = @actor.status_info
    s = Surface.new([@@STATUS_WIDTH, @@STATUS_HEIGHT])
    s.fill(:green)
    @menu_helper.render_text_to(s, info_lines, TextRenderingConfig.new(0, 0, 0,@@MENU_LINE_SPACING))
    s
  end
end
class SortInventoryAction
  attr_reader :text
  def initialize(text, game, menu_helper)
    @text = text
    @game = game
    @menu_helper = menu_helper
  end
  def activate(cursor_position, game, section_position)
    puts "TODO re-sort inventory"
  end



end
class InventoryDisplayAction
  attr_reader :text
  def initialize(text, game, menu_helper)
    @text = text
    @game = game
    @menu_helper = menu_helper
    @selected_option = nil
  end

  def activate(cursor_position, game, section_position, subsection_position=nil, option_position=nil)
    if !option_position.nil?
      item = info[subsection_position]
      target = party_members[option_position]
      target.consume_item(item) #TODO this is similar to ItemAction refactor
    elsif subsection_position.nil?
      @menu_helper.set_active_subsection(section_position)
    end
    return !subsection_position.nil?
  end
  def surface_for(posn)
    item = info[posn]
    s = Surface.new([@@STATUS_WIDTH, @@STATUS_HEIGHT])
    s.fill(:white)
    member_names = party_members.collect {|m| m.name}
    @menu_helper.render_text_to(s,member_names , TextRenderingConfig.new(0, 0, 0,@@MENU_LINE_SPACING))
    s

  end

  def option_at(idx)
    party_members
  end

  def party_members
    @game.party_members
  end

  def info
    @game.inventory_info
  end

  def details
    info_lines = info.collect {|item| item.to_info}
    s = Surface.new([@@STATUS_WIDTH, @@STATUS_HEIGHT])
    s.fill(:yellow)
    @menu_helper.render_text_to(s, info_lines, TextRenderingConfig.new(0, 0, 0,@@MENU_LINE_SPACING))
    s
  end

  def size
    info.size
  end
end
class KeyInventoryDisplayAction < InventoryDisplayAction
end
class AbstractLayer
  include FontLoader #TODO unify resource loading
  attr_accessor :active

  def initialize(screen, layer_width, layer_height)
    @screen = screen
    @active = false
    @layer = Surface.new([layer_width, layer_height])
    @font = load_font("FreeSans.ttf")
    @text_rendering_helper = TextRenderingHelper.new(@layer, @font)
  end

  def toggle_activity
    @active = !@active
  end

  alias_method :active?, :active
  alias_method :visible, :active
  alias_method :toggle_visibility, :toggle_activity
end
class NotificationsLayer < AbstractLayer
  def initialize(screen, game)
    super(screen, @@NOTIFICATION_LAYER_WIDTH, @@NOTIFICATION_LAYER_HEIGHT)
    @notifications = []
    @config = TextRenderingConfig.new(@@NOTIFICATION_TEXT_INSET, 0, @@NOTIFICATION_TEXT_INSET, @@NOTIFICATION_LINE_SPACING )
  end

  def add_notification(notification)
    @notifications << notification
    @active = true
  end

  def config_for(idx)
    TextRenderingConfig.new(@@NOTIFICATION_TEXT_INSET, 0, @@NOTIFICATION_TEXT_INSET, @@NOTIFICATION_LINE_SPACING * idx)
  end

  def draw
    @layer.fill(:black)

    @notifications.delete_if do |notif|
      notif.dead?
    end

    msgs = @notifications.collect {|n| n.message}
    @text_rendering_helper.render_lines_to_layer(msgs, @config)
    @notifications.each {|n| n.displayed}
    
    unless @notifications.empty?
      @layer.blit(@screen, @notifications[0].location)
    end
    
    @active = false if @notifications.empty?
  end
end
class DialogLayer < AbstractLayer
  attr_accessor :visible, :text
  include FontLoader #TODO unify resource loading

  def initialize(screen, game)
    super(screen, screen.w/2 - @@LAYER_INSET, screen.h/2 - @@LAYER_INSET)
    @layer.fill(:red)
    @layer.alpha = 192
    @text = "UNSET"
  end

  def toggle_visibility
    @visible = !@visible
  end

  def draw
    text_surface = @font.render @text.to_s, true, [16,222,16]
    text_surface.blit @layer, [@@TEXT_INSET,@@TEXT_INSET]
    @layer.blit(@screen, [@@LAYER_INSET,@@LAYER_INSET])
  end

  def displayed
    #TODO other logic like next page, gifts, etc goes here
    @active = false
  end
end
class MenuLayer < AbstractLayer
  include FontLoader #TODO unify resource loading
  attr_accessor :active

  alias_method :active?, :active
  alias_method :visible, :active
  alias_method :toggle_visibility, :toggle_activity

  extend Forwardable
  def_delegators :@menu_helper, :enter_current_cursor_location, :move_cursor_down,
    :move_cursor_up, :cancel_action, :reset_indices

  def initialize(screen, game)
    super(screen, (screen.w) - 2*@@MENU_LAYER_INSET, (screen.h) - 2*@@MENU_LAYER_INSET)
    @layer.fill(:red)
    @layer.alpha = 192
    @game = game
    @menu_helper = MenuHelper.new(screen, @layer, @text_rendering_helper, [], @@MENU_LINE_SPACING,@@MENU_LINE_SPACING)
  end

  def menu_sections_for(chars)
    [MenuSection.new("Status", chars.collect {|m| StatusDisplayAction.new(m, @menu_helper)}),
      MenuSection.new("Inventory", [InventoryDisplayAction.new("All Items", @game, @menu_helper), KeyInventoryDisplayAction.new("Key Items", @game, @menu_helper), SortInventoryAction.new("Sort", @game, @menu_helper)]),
      MenuSection.new("Levelup", chars.collect {|m| LevelUpAction.new(m, @menu_helper)}),
      MenuSection.new("Equip", chars.collect {|m| UpdateEquipmentAction.new(m, @menu_helper, @game)}),
      MenuSection.new("Save", [SaveMenuAction.new("Slot 1")]),
      MenuSection.new("Load", [LoadMenuAction.new("Slot 1")])
    ]
  end


  def rebuild_menu_sections
    menu_sections_for(@game.party_members)
  end
  def menu_layer_config

    mlc = MenuLayerConfig.new
    mlc.main_menu_text = TextRenderingConfig.new(@@MENU_TEXT_INSET, 0, @@MENU_TEXT_INSET, @@MENU_LINE_SPACING)
    mlc.section_menu_text = TextRenderingConfig.new(3 * @@MENU_TEXT_INSET + @@MENU_TEXT_WIDTH + @@MENU_LINE_SPACING, 0, @@MENU_TEXT_INSET, @@MENU_LINE_SPACING)
    mlc.in_subsection_cursor = TextRenderingConfig.new(2 * @@MENU_TEXT_INSET + 4*@@MENU_TEXT_WIDTH, 0, 2 * @@MENU_TEXT_INSET, @@MENU_LINE_SPACING)
    mlc.in_option_section_cursor = TextRenderingConfig.new(2 * @@MENU_TEXT_INSET + 4*@@MENU_TEXT_WIDTH, 0, 3 * @@MENU_TEXT_INSET, @@MENU_LINE_SPACING)
    mlc.in_section_cursor = TextRenderingConfig.new(2 * @@MENU_TEXT_INSET + 4*@@MENU_TEXT_WIDTH, 0, @@MENU_TEXT_INSET, @@MENU_LINE_SPACING)
    mlc.main_cursor = TextRenderingConfig.new(2 * @@MENU_TEXT_INSET + @@MENU_TEXT_WIDTH, 0, @@MENU_TEXT_INSET, @@MENU_LINE_SPACING)
    mlc.layer_inset_on_screen = [@@MENU_LAYER_INSET,@@MENU_LAYER_INSET]
    mlc.details_inset_on_layer = [@@MENU_DETAILS_INSET_X, @@MENU_DETAILS_INSET_Y]
    mlc.options_inset_on_layer = [@@MENU_OPTIONS_INSET_X, @@MENU_OPTIONS_INSET_Y]
    mlc
  end

  def draw()
    @layer.fill(:red)
    @menu_helper.replace_sections(rebuild_menu_sections)
    @menu_helper.draw(menu_layer_config, @game)
  end
end
class BattleLayer < AbstractLayer
  extend Forwardable
  def_delegators :@battle, :participants, :current_battle_participant_offset
  def_delegators :@game, :inventory
  attr_reader :battle
  include EventHandler::HasEventHandler
  def initialize(screen, game)
    super(screen, screen.w - 50, screen.h - 50)
    @layer.fill(:orange)
    @text_rendering_helper = TextRenderingHelper.new(@layer, @font)
    @battle = nil
    @menu_helper = nil
    @game = game
    @battle_hud = BattleHud.new(@screen, @text_rendering_helper, @layer)
    sections = [MenuSection.new("Exp",[EndBattleMenuAction.new("Confirm", self)]),
      MenuSection.new("Items", [EndBattleMenuAction.new("Confirm", self)])]
    @end_of_battle_menu_helper = MenuHelper.new(screen, @layer, @text_rendering_helper, sections, @@MENU_LINE_SPACING,@@MENU_LINE_SPACING)
    make_magic_hooks({ClockTicked => :update})
  end
  def update( event )
    return unless @battle and !@battle.over?
    dt = event.seconds # Time since last update
    @battle.accumulate_readiness(dt)
  end
  def start_battle(game, universe, player, monster)
    @active = true
    @battle = Battle.new(game, universe, player, monster, self)
    
    @menu_helper = BattleMenuHelper.new(@battle, @screen, @layer, @text_rendering_helper, [], @@MENU_LINE_SPACING,@@MENU_LINE_SPACING)

    sections = player.party.collect {|hero|  HeroMenuSection.new(hero, [AttackMenuAction.new("Attack", self, @menu_helper), ItemMenuAction.new("Item", self, @menu_helper, @game)])}
    @menu_helper.replace_sections(sections)
  end
  def end_battle
    @active = false
    @battle.end_battle
  end
  def menu_layer_config

    mlc = MenuLayerConfig.new
    mlc.main_menu_text = TextRenderingConfig.new(@@MENU_TEXT_INSET, @@MENU_TEXT_WIDTH, @layer.h - 125, 0)
    mlc.section_menu_text = TextRenderingConfig.new(@@MENU_TEXT_INSET, @@MENU_TEXT_WIDTH, @layer.h - 150, 0)
    mlc.in_section_cursor = TextRenderingConfig.new(@@MENU_TEXT_INSET , @@MENU_TEXT_WIDTH, @layer.h - 175, 0)
    mlc.in_subsection_cursor = BattleParticipantCursorTextRenderingConfig.new([AttackMenuAction], 2 * @@MENU_TEXT_INSET + 4*@@MENU_TEXT_WIDTH, 0, @@MENU_TEXT_INSET, @@MENU_LINE_SPACING)
    mlc.in_option_section_cursor = BattleParticipantCursorTextRenderingConfig.new([ItemMenuAction], 2 * @@MENU_TEXT_INSET + 4*@@MENU_TEXT_WIDTH, 0, @@MENU_TEXT_INSET, @@MENU_LINE_SPACING)
    mlc.main_cursor = TextRenderingConfig.new(@@MENU_TEXT_INSET , @@MENU_TEXT_WIDTH, @layer.h - 100, 0)
    mlc.layer_inset_on_screen = [@@LAYER_INSET,@@LAYER_INSET]
    mlc.details_inset_on_layer = [@@MENU_DETAILS_INSET_X, @@MENU_DETAILS_INSET_Y]
    mlc.options_inset_on_layer = [@@MENU_OPTIONS_INSET_X, @@MENU_OPTIONS_INSET_Y]

    mlc
  end
  def end_battle_menu_layer_config

    mlc = MenuLayerConfig.new
    mlc.main_menu_text = TextRenderingConfig.new(@@MENU_TEXT_INSET, @@MENU_TEXT_WIDTH, 50, 0)
    mlc.section_menu_text = TextRenderingConfig.new(@@MENU_TEXT_INSET, @@MENU_TEXT_WIDTH, 150, 0)
    mlc.in_section_cursor = TextRenderingConfig.new(@@MENU_TEXT_INSET , @@MENU_TEXT_WIDTH,200, 0)
    mlc.main_cursor = TextRenderingConfig.new(@@MENU_TEXT_INSET , @@MENU_TEXT_WIDTH,100, 0)
    mlc.layer_inset_on_screen = [@@LAYER_INSET,@@LAYER_INSET]
    mlc
  end
  def draw()
    @layer.fill(:orange)
    if @battle.over?
      if @battle.player_alive?
        @end_of_battle_menu_helper.draw(end_battle_menu_layer_config, @game)
      else
        puts "you died ... game should be over... whatever"
        @end_of_battle_menu_helper.draw(end_battle_menu_layer_config, @game)
      end
    else
      @battle.monster.draw_to(@layer)
      @menu_helper.draw(menu_layer_config, @game)
      @battle_hud.draw(menu_layer_config, @game, @battle)
    end
  end

  def enter_current_cursor_location(game)
    if @battle.over?
      @end_of_battle_menu_helper.enter_current_cursor_location(game)
    else
      @menu_helper.enter_current_cursor_location(game)
    end
  end
  
  def move_cursor_down
    send_action_to_target(:move_cursor_down)
  end
  def move_cursor_up
    send_action_to_target(:move_cursor_up)
  end

  def cancel_action
    send_action_to_target(:cancel_action)
  end

  def send_action_to_target(sym)
    target = @battle.over? ? @end_of_battle_menu_helper : @menu_helper
    target.send(sym)
  end
end

class MenuSection

  attr_reader :text, :content
  def initialize(text, content)
    @text = text
    @content = content
  end
  def content_at(i)
    @content[i]
  end
  def text_contents
    @content.collect {|ma| ma.text}
  end
end
class HeroMenuSection < MenuSection
  def initialize(hero, content)
    super(hero.name, content)
    @hero = hero
  end
end

class TextRenderingConfig
  attr_reader :xc,:xf,:yc,:yf
  def initialize(xc,xf,yc,yf)
    @xc = xc
    @xf = xf
    @yc = yc
    @yf = yf
  end

  def cursor_offsets_at(position, game, menu_action)
    [@xc + @xf * position, @yc + @yf * position]
  end
end

class BattleParticipantCursorTextRenderingConfig < TextRenderingConfig

  def initialize(klasses, xc,xf,yc,yf)
    super(xc,xf,yc,yf)
    @klasses = klasses
  end

  def matches_menu_action?(ma)
    @klasses.include?(ma.class)
  end

  def cursor_offsets_at(position, game, menu_action)
    if matches_menu_action?(menu_action)
      offset = game.current_battle_participant_offset(position)
    else
      puts "trouble brewin" if position.nil?
      offset = [@@BATTLE_INVENTORY_XC + @@BATTLE_INVENTORY_XF * position, @@BATTLE_INVENTORY_YC + @@BATTLE_INVENTORY_YF * position]
    end
    offset
  end
end

class MenuLayerConfig
  attr_accessor :main_menu_text, :section_menu_text, :in_section_cursor, 
    :main_cursor, :layer_inset_on_screen, :details_inset_on_layer, 
    :options_inset_on_layer, :in_subsection_cursor, :in_option_section_cursor

end

class NoopAction
  def perform(src,dest)
    puts "nothing to do, noop action" #TODO consume readiness?
  end
end


class MenuAction
  attr_reader :text
  def initialize(text, action=NoopAction.new)
    @text = text
    @action = action
  end

  def activate(main_menu_idx, game, submenu_idx)
    puts "This is a no-op action: #{@text}"
  end
end

class DamageCalculationHelper
  def calculate_damage(src,dest)
    puts "uh oh, #{src} does 0 damage " if src.damage == 0
    src.damage #TODO take dest defense into account etc
  end
end


class AttackAction
  def initialize(action_cost=@@ATTACK_ACTION_COST)
    @action_cost = action_cost
  end
  def perform(src, dest)
    dest.take_damage(DamageCalculationHelper.new.calculate_damage(src, dest))
    src.consume_readiness(@action_cost)
  end
end
class AttackMenuAction < MenuAction
  def initialize(text, battle_layer, menu_helper)
    super(text, AttackAction.new)
    @battle_layer = battle_layer
    @menu_helper = menu_helper
  end

  def activate(party_member_index, game, action_idx, subsection_position=nil, option_position=nil)
    @menu_helper.set_active_subsection(action_idx)

    return false unless subsection_position
    battle = @battle_layer.battle

    hero = battle.player.party.members[party_member_index]
    target = battle.current_battle_participant(subsection_position)
    puts "I am going to attack #{target}"
    @action.perform(hero, target)
    msg = "attacked for #{hero.damage} damage"
#    msg += "hero #{hero} killed #{battle.monster}" if battle.monster.dead?
    game.add_notification(BattleScreenNotification.new("Attacked for #{hero.damage}"))
    false
  end

  def size
    @battle_layer.participants.size
  end

  def details
    false
  end
end

class ItemAction
  def initialize(action_cost=@@ITEM_ACTION_COST)
    @action_cost = action_cost
  end
  def perform(src, dest, item)
    dest.consume_item(item)
    src.consume_readiness(@action_cost)
  end
end

class ItemMenuAction < MenuAction
  def initialize(text, battle_layer, menu_helper, game)
    super(text, ItemAction.new)
    @battle_layer = battle_layer
    @menu_helper = menu_helper
    @game = game
  end

  def activate(party_member_index, game, action_idx, subsection_position=nil, option_position=nil)
    @menu_helper.set_active_subsection(action_idx)

    return false unless subsection_position
    return true unless option_position
    
    battle = @battle_layer.battle
    hero = battle.player.party.members[party_member_index]
    item = battle.inventory_item_at(subsection_position)
    target = battle.current_battle_participant(option_position)
    puts "target is: #{option_position}->#{target}"
    @action.perform(hero, target, item)
    game.add_notification(BattleScreenNotification.new("Item used: #{item}"))
    false
  end

  def option_at(idx)
    @battle_layer.participants
  end

  def size
    @battle_layer.inventory.size
  end

  def info
    @game.inventory_info
  end

  def surface_for(posn)
    false
  end


  def details
    info_lines = info.collect {|item| item.to_info}
    s = Surface.new([@@STATUS_WIDTH, @@STATUS_HEIGHT])
    s.fill(:purple)
    @menu_helper.render_text_to(s, info_lines, TextRenderingConfig.new(0, 0, 0,@@MENU_LINE_SPACING))
    s
  end


end
class EndBattleMenuAction < MenuAction
  def initialize(text, battle_layer)
    super(text)
    @battle_layer = battle_layer
  end

  def activate(menu_idx, game, submenu_idx)
    @battle_layer.end_battle
  end
end

class SaveLoadMenuAction < MenuAction
  def save_slot(idx)
    "save-slot-#{idx}.json"
  end
end

class SaveMenuAction < SaveLoadMenuAction
  def activate(menu_idx, game, submenu_idx)
    puts "saving: #{game.player}"
    json = JSON.generate(game.player)
    slot = save_slot(submenu_idx)
    save_file = File.open(slot, "w")
    save_file.puts json
    save_file.close
    puts "saving to slot #{submenu_idx}, json data is: "
    puts "player was at #{game.player.px} and #{game.player.py} at save time"
    puts "save action believes the menu layer to be active? #{game.universe.menu_layer.active}"
    game.toggle_menu
    game.add_notification(WorldScreenNotification.new("Saved to #{slot}"))
  end
end

class ReloaderHelper
  def replace(game, json_player)
    puts "player is at #{game.player.px} and #{game.player.py} at load time"
    uni = json_player.universe
    orig_uni = game.universe
    universe = Universe.new(uni.current_world_idx, uni.worlds, orig_uni.game_layers, orig_uni.sound_effects)

    puts "universe has current world: #{universe.current_world_idx}"
    universe.replace_world_pallettes(orig_uni)
    universe.replace_world_bgsurfaces(orig_uni)
    universe.replace_world_bgmusics(orig_uni)
    
    universe.reblit_backgrounds
    puts "backgrounds rebuilt"
    player = Player.new(json_player.px, json_player.py,  universe, json_player.party, json_player.filename, json_player.hero_x_dim, json_player.hero_y_dim, game.screen.w/2, game.screen.h/2)
    #TODO update tile coords for player
    game.universe = universe
    game.player = player
    game.update_player_tile_coords
    game.remove_all_hooks
    game.rebuild_event_hooks
    game.universe.menu_layer.toggle_activity
    game.rebuild_hud
    game.reset_menu_positions
    puts "reloading should be done"
  end
end

module ScreenOffsetHelper
  def offset_from_screen(location, viewer_position, screen_extent)
    location - viewer_position + screen_extent
  end
end

class LoadMenuAction < SaveLoadMenuAction
  def activate(menu_idx, game, submenu_idx)
    slot = save_slot(submenu_idx)
    puts "load from #{slot}"

    data = IO.readlines(slot)

    rebuilt = JSON.parse(data.join(" "))
    puts "got rebuilt: #{rebuilt.class} "
    ReloaderHelper.new.replace(game, rebuilt)
    game.add_notification(WorldScreenNotification.new("Loaded from #{slot}"))
  end
end

class CharacterAttributes
  attr_accessor :hp, :mp, :strength, :defense, :magic_power, :magic_defense, :agility, :luck
  def initialize(hp,mp, strength, defense, magic_power, magic_defense, agility, luck)
    @hp = hp
    @mp = mp
    @strength = strength
    @defense = defense
    @magic_power = magic_power
    @magic_defense = magic_defense
    @agility = agility
    @luck = luck
  end

  def add_attributes(other)
    @hp += other.hp
    @mp += other.mp
    @strength += other.strength
    @defense += other.defense
    @magic_power += other.magic_power
    @magic_defense += other.magic_defense
    @agility += other.agility
    @luck += other.luck
  end

  include JsonHelper
  def json_params
    [@hp,@mp, @strength, @defense, @magic_power, @magic_defense, @agility, @luck ]
  end
end

class CharacterState
  attr_accessor :current_hp, :current_mp, :status_effects, :experience, :level_points
  extend Forwardable
  def_delegators :@attributes, :hp, :mp, :add_attributes
  def initialize(attributes, exp=nil, chp=nil, cmp=nil, statii=nil, lvp=nil)
    @attributes = attributes
    @current_hp = chp.nil? ? attributes.hp : chp
    @current_mp = cmp.nil? ? attributes.mp : cmp
    @status_effects = statii.nil? ? [] : statii
    @experience = exp.nil? ? 0 : exp
    @level_points = lvp.nil? ? 0 : lvp
  end

  def dead?
    @current_hp <= 0
  end

  def take_damage(damage)
    @current_hp -= damage
  end
  def damage
    #TODO this should be a more complex formula than just Str :)
    @attributes.strength
  end

  def gain_experience(pts)
    @experience += pts
  end
  def hp_ratio
    @current_hp.to_f/@attributes.hp.to_f
  end

  def subtract_level_points(pts)
    @level_points -= pts
  end
  def add_effects(other_state)
    @current_hp += other_state.current_hp
    @current_mp += other_state.current_mp
    #TODO status effects, core attributes, etc
    
  end

  include JsonHelper
  def json_params
    [ @attributes, @experience, @current_hp, @current_mp, @status_effects]
  end

end

class EquipmentInfo
  def initialize(slot, equipped)
    @slot = slot
    @equipped = equipped
  end

  def to_s
    equipment_name = @equipped.nil? ? "empty" : @equipped.name
    "#{@slot}: #{equipment_name}"
  end
end


class EquipmentHolder
  def initialize
    @equipped = Hash.new
  end

  def equipped_on(slot)
    @equipped[slot]
  end

  def equip_on(slot, gear)
    @equipped[slot] = gear
  end

  def equip_in_slot_index(idx, gear)
    equip_on(slots[idx], gear)
  end

  def equipment_info
    slots.collect {|slot| EquipmentInfo.new(slot, equipped_on(slot))}
  end

  def slots
    [:head, :body, :feet, :left_hand, :right_hand]
  end
end

class CharacterAttribution
  extend Forwardable
  def_delegators :@state, :dead?, :take_damage, :damage, :gain_experience, :experience, :current_hp, :hp, :hp_ratio
  def_delegators :@equipment, :equipment_info, :equip_in_slot_index

  def initialize(state, equipment)
    @state = state
    @equipment = equipment
  end

  def consume_item(item)
    @state.add_effects(item.effects)
    item.consumed
  end

  def consume_level_up(attr_idx) #TODO this might not be the best way to pass this?
    bonus = 1
    cost = 1
    #TODO 1:1 level-stat tradeoff is not valid

    arr = 0.upto(7).collect {|n| n == attr_idx ? bonus : 0}
    @state.add_attributes(CharacterAttributes.new(*arr))
    @state.subtract_level_points(cost)
  end


  def stats_ordering
    [:hp, :mp, :exp, :lvp]
  end

  def stats_mapping
    m = {}
    m[:hp] = "HP: #{@state.current_hp}/#{@state.hp}"
    m[:mp] = "MP: #{@state.current_mp}/#{@state.mp}"
    m[:exp] = "EXP: #{@state.experience}"
    m[:lvp] = "LVP: #{@state.level_points}"
    m
  end

  def status_info
    stats_ordering.collect {|sk| stats_mapping[sk]}
  end
  include JsonHelper
  def json_params
    [ @state]
  end
end

class StaticPathFollower
  def update(keys)
    #NOOP
  end
  include JsonHelper
  def json_params
    []
  end

end

class RepeatingPathFollower

  def initialize(path, ticks_per_char)
    @path = path
    @ticks_per_path_unit = ticks_per_char
    @ticks_seen = 0
    @path_idx = 0

  end

  def update(keys)
    @ticks_seen += 1
    if @ticks_seen >= @ticks_per_path_unit
      @ticks_seen = 0
      new_idx = (@path_idx + 1) % @path.length
      keys.switch(keysym_at(@path_idx),keysym_at(new_idx))
      @path_idx = new_idx
    end
  end




  def keysym_at(idx)
    char_syms[@path.slice(idx,1)]
  end

  def char_syms
    m = {}
    m["L"] = :left
    m["U"] = :up
    m["R"] = :right
    m["D"] = :down
    m
  end

  include JsonHelper
  def json_params
    [@path, @ticks_per_path_unit]
  end



end

class TargetMatcher
  def initialize(target)
    @target = target
  end

  def target_is_enemy?
    @target.downcase.include?("enemy")
  end

  def is_enemy_of?(src,target)
    src.class != target.class
  end
  def matches?(src,target)
    if target_is_enemy?
      return is_enemy_of?(src,target)
    end
    puts "target #{@target} matches #{target}?"
    true
  end
end

class ConditionMatcher
  def initialize(cond)
    @condition = cond
  end
  def matches?(src, target)
    puts "condition #{@condition} matches #{target} ?"
    true
  end
end

class ActionInvoker
  def initialize(action_desc)
    @action = build_from(action_desc)
  end

  def build_from(action_desc)
    return AttackAction.new if action_desc.downcase.include?("attack")
  end

  def perform_on(src, dest)
    @action.perform(src,dest)
  end
end
class BattleTactic
  extend Forwardable
  def_delegators :@action, :perform_on
  
  attr_reader :target, :condition, :action
  def initialize(desc)
    parse(desc)
  end

  def parse(desc)
    target_and_rest = desc.split(":")
    cond_and_act = target_and_rest[1].split("->")
    @target = TargetMatcher.new(target_and_rest[0])
    @condition = ConditionMatcher.new(cond_and_act[0])
    @action = ActionInvoker.new(cond_and_act[1])
  end

  def matches?(source, target)
    @target.matches?(source, target) and @condition.matches?(source, target)
  end

end

class BattleStrategy
  def initialize(tactics)
    @tactics = tactics
  end

  def take_battle_turn(actor, battle)
    puts "take #{actor}s battle turn in #{battle}"
    
    battle.participants.each {|foe| #TODO this should be each battle participant, including self
      @tactics.each {|tactic|
        if tactic.matches?(actor, foe)
          tactic.perform_on(actor, foe)
        end
      }
    }

    actor.consume_readiness(@@NOOP_ACTION_COST)
  end
end

class ArtificialIntelligence
  extend Forwardable

  def_delegators :@battle_strategy, :take_battle_turn

  def initialize(follow_strategy, battle_strategy)
    @follow_strategy = follow_strategy
    @battle_strategy = battle_strategy
  end

  def update(event)
    @follow_strategy.update(event)
  end
end

class Monster
  include ScreenOffsetHelper
  include Sprites::Sprite
  include EventHandler::HasEventHandler

  extend Forwardable
  def_delegators :@coordinate_helper, :px, :py, :collides_on_x?, :collides_on_y?

  def_delegators :@character_attribution, :take_damage, :experience, :dead?, :damage, :consume_item
  def_delegators :@readiness_helper, :consume_readiness
  

  attr_reader :inventory, :player
  def initialize(player, universe, filename, px, py, npc_x = @@MONSTER_X, npc_y = @@MONSTER_Y, inventory=Inventory.new(255), character_attrib=nil, ai=nil)
    @npc_x = npc_x
    @npc_y = npc_y
    @filename = filename
    @universe = universe
    @player = player
    @ai = ai
    @animated_sprite_helper = AnimatedSpriteHelper.new(filename, px, py, @npc_x, @npc_y)
    @keys = AlwaysDownMonsterKeyHolder.new
    @coordinate_helper = MonsterCoordinateHelper.new(px, py, @keys, @universe, @npc_x, @npc_y,100, 300,200)
    @animation_helper = AnimationHelper.new(@keys, 3)
    @readiness_helper = BattleReadinessHelper.new(@@MONSTER_START_BATTLE_PTS, @@MONSTER_BATTLE_PTS_RATE)
    @character_attribution = character_attrib
    @inventory = inventory
    
    make_magic_hooks(
      ClockTicked => :update
    )
  end


  def is_blocking?
    false
  end

  def draw(surface,x,y,sx,sy)

    tx = offset_from_screen(@coordinate_helper.px, x, sx/2)
    ty = offset_from_screen(@coordinate_helper.py, y, sy/2)
    @animated_sprite_helper.image.blit surface, [tx,ty,@npc_x,@npc_y]
  end

  def draw_to(layer)
    @animated_sprite_helper.image.blit layer, [0,0,@npc_x,@npc_y]
  end

  def update(event)
    dt = event.seconds # Time since last update
    @animation_helper.update_animation(dt) { |frame| @animated_sprite_helper.replace_avatar(frame) }
    @coordinate_helper.update_accel
    @coordinate_helper.update_vel( dt )
    @coordinate_helper.update_pos( dt, self )
    @ai.update(@keys)
  end

  def distance_to(x,y)
    [(@coordinate_helper.px - x).abs, (@coordinate_helper.py - y).abs]
  end

  def nearby?(x,y, distx, disty)
    dist = distance_to(x,y)
    (dist[0] < distx) and (dist[1] < disty)
  end

  def interact(game, universe, player)
    game.battle_begun(universe,player)
    universe.battle_layer.start_battle(game, universe, player, self)
  end

  def add_readiness(pts, battle)
    @readiness_helper.add_readiness(pts)
    if @readiness_helper.ready?
      @ai.take_battle_turn(self, battle)
    end
  end



  include JsonHelper
  def json_params
    [ @filename, @animated_sprite_helper.px, @animated_sprite_helper.py, @npc_x, @npc_y, @inventory, @character_attribution, @ai]
  end
end

class TalkingNPC < Monster
  def is_blocking?
    true
  end

  def initialize(player, universe, text, filename, px, py, npc_x, npc_y, inv=nil, attrib=nil, ai=nil)
    super(player, universe,filename, px, py, npc_x, npc_y, inv, attrib, ai)
    @text = text
  end

  def interact(game, universe, player)
    puts "display dialog '#{@text}' from #{self}"
    universe.dialog_layer.active = true
    universe.dialog_layer.text = @text
  end

  include JsonHelper
  def json_params
    [ @text, @filename, @animated_sprite_helper.px, @animated_sprite_helper.py, @npc_x, @npc_y, @inventory, @character_attribution, @ai]
  end
end

class BattleReadinessHelper
  attr_reader :points, :starting_points, :growth_rate

  def initialize(starting_points, growth_rate)
    @starting_points = starting_points
    @points = starting_points
    @growth_rate = growth_rate
    @points_needed_for_ready = @@READINESS_POINTS_NEEDED_TO_ACT
  end

  def add_readiness(points)
    @points += points * @growth_rate
  end

  def consume_readiness(pts)
    @points -= pts
  end

  def ready?
    @points >= @points_needed_for_ready
  end

  def ready_ratio
    @points.to_f/@points_needed_for_ready.to_f
  end
end

class BattleVictoryHelper

  def monster_killed(universe, monster)
    universe.current_world.delete_monster(monster)
  end
  def give_spoils(player,monster)
    player.gain_experience(monster.experience)
    player.gain_inventory(monster.inventory)

  end
end

class Battle
  extend Forwardable
  def_delegators :@player, :party, :dead?, :inventory_item_at
  
  attr_reader :monster, :player
  def initialize(game, universe, player, monster, battle_layer)
    @game = game
    @player = player
    @monster = monster #TODO allow multi-monster battles
    @universe = universe
  end

  def accumulate_readiness(dt)
    points = dt * @@READINESS_POINTS_PER_SECOND
    @player.add_readiness(points)
    @monster.add_readiness(points, self)
  end

  def monsters
    [@monster]
  end

  def heroes
    @player.party.members
  end

  def participants
    #TODO check to see class of actor, for now only monsters use AI battle strategies
    monsters + heroes
  end

  def current_battle_participant(idx)
    participants[idx]
  end


  def current_battle_participant_offset(idx)

    member = current_battle_participant(idx)

    if member.is_a? Monster
      rv = [15 + 15 * idx, 15]
    else
      rv = [ 15 + 65 * (idx - monsters.size), 400]
    end
    #TODO return the cursor offsets for this guy
    rv
  end

  def over?
    @monster.dead? or @player.dead?
  end

  def player_alive?
    !@player.dead?
  end

  def end_battle
    @game.battle_completed
    helper = BattleVictoryHelper.new
    helper.give_spoils(@player, @monster)
    helper.monster_killed(@universe,@monster)
  end
end



class EventManager
  def swap_event_sets(game, already_active, toggled_hooks, menu_active_hooks)
    if already_active
      menu_active_hooks.each {|hook|
        game.remove_hook(hook)
      }
      toggled_hooks.each {|hook|
        game.append_hook(hook)
      }
    else
      toggled_hooks.each {|hook|
        game.remove_hook(hook)
      }
      menu_active_hooks.each {|hook|
        game.append_hook(hook)
      }
    end

  end
end

class JsonSurface < Surface
  def initialize(size)
    super(size)
    @size = size
  end

end

class JsonLoadableSurface 
  extend Forwardable
  def_delegators :@surface, :blit

  def initialize(filename, blocking)
    @filename = filename
    @blocking = blocking
    @surface = Surface.load(filename)
  end

  def is_blocking?
    @blocking
  end
end


class TopoMapFactory
  def self.build_map(filename,bgx, bgy)
    lines = IO.readlines(filename)
    data = []
    lines.each {|line| data += line.strip.split(//)}

    chrs = lines[0].strip.split(//)
    x = chrs.size
    y = lines.size

    TopoMap.new(x,y,bgx, bgy, data)
  end
end


class InterpretedMap
  attr_reader :topo_map, :pallette

  extend Forwardable
  def_delegators :@topo_map, :left_side, :right_side, :bottom_side, :top_side,
    :update, :x_offset_for_world, :y_offset_for_world, :data_at

  def initialize(topo_map, pallette)
    @topo_map = topo_map
    @pallette = pallette
  end
  def blit_foreground(screen,px, py)
    @topo_map.blit_foreground(@pallette, screen,px, py)
  end
  def blit_to(surface)
    @topo_map.blit_to(@pallette, surface)
  end

  def [](key)
    @pallette[key]
  end
  
  def interpret(tilex, tiley)
    self[data_at(tilex,tiley)]
  end

  def can_walk_at?(xi,yi)
    d = @topo_map.data_at(xi,yi)
    tile = self[d]
    return true if tile.nil?

    !tile.is_blocking?
  end

  def replace_pallette(orig_interpreter)
    @pallette = orig_interpreter.pallette
  end

  include JsonHelper
  def json_params
    [ @topo_map, nil]
  end
end

class WorldStateFactory
  def self.build_world_state(bg_file, int_file, pallette, interaction_pallette, bgx, bgy, npcs, bgm)
    bgsurface = JsonSurface.new([bgx,bgy])
    bg = InterpretedMap.new(TopoMapFactory.build_map(bg_file, bgx, bgy), pallette)
    inter = InterpretedMap.new(TopoMapFactory.build_map(int_file, bgx, bgy), interaction_pallette)
    WorldState.new(bg, inter, npcs, bgsurface, bgm)
  end
end

class Pallette
  def initialize(default_value, updated=nil)
    @default_value = default_value
    if updated.nil?
      @pal = Hash.new(default_value)
    else
      @pal = updated
    end
    
  end

  def []=(key,value)
    @pal[key] = value
  end

  def [](key)
    @pal[key]
  end

  def blit(target, xi, yi, datum, xsize, ysize)
    datum.blit(target, [xi*xsize, yi * ysize])
  end
end

class SurfaceBackedPallette < Pallette

  attr_reader :tile_x, :tile_y
  def initialize(filename, x, y, pal=nil)
    super(nil,pal)
    @surface = Surface.load(filename)
    @tile_x = x
    @tile_y = y
  end
  def offsets(key)
    @pal[key]
  end


  def [](key)
    entry = @pal[key]
    offset_x = entry.offsets[0]
    offset_y = entry.offsets[1]
    s = Surface.new([@tile_x,@tile_y])
    @surface.blit(s,[0,0], [offset_x * @tile_x, offset_y * @tile_y, @tile_x, @tile_y]  )
    SBPResult.new(s, entry.actionable, self)
  end
end


class ISBPEntry
  attr_reader :offsets, :actionable
  def initialize(offsets, actionable)
    @offsets = offsets

    @actionable = actionable
  end

end

class CISBPEntry < ISBPEntry
  attr_reader :filename
  def initialize(conf, actionable)
    super(conf.slice(1,2), actionable)
    @filename = conf[0]
  end

end

class SBPEntry < ISBPEntry
  alias_method :walkable, :actionable
end
class ISBPResult
  include ScreenOffsetHelper

  attr_reader :surface
  def initialize(sdl_surface, actionable, wrapped_surface)
    @surface=  sdl_surface
    @actionable = actionable
    @wrapped_surface = wrapped_surface
  end
  extend Forwardable
  def_delegators :@actionable, :activate
  def_delegators :@surface, :w,:h
  #  def activate(player, worldstate, tilex, tiley)
  #    @actionable.activate(player, worldstate, tilex, tiley)
  #  end

  def screen_position_relative_to(px,py,xi,yi,sextx,sexty)
    tx = @wrapped_surface.tile_x
    ty = @wrapped_surface.tile_y
    xoff = offset_from_screen(xi*tx, px, sextx)
    yoff = offset_from_screen(yi*ty, py, sexty)
    [xoff,yoff]
  end

  def blit(screen, px,py,xi, yi)
    @surface.blit(screen, screen_position_relative_to(px,py,xi,yi, screen.w/2, screen.h/2))
  end

  def blit_onto(screen, args)
    @surface.blit(screen, args)
  end
  def is_blocking?
    @actionable.is_blocking?
  end
end

class SBPResult < ISBPResult
  def blit(screen, offsets)
    @surface.blit(screen, offsets)
  end

  def is_blocking?
    @actionable
  end

end


class CompositeInteractableSurfaceBackedPallette
  def initialize(configs)
    @backing = {}
    configs.each {|config|
      filename = config[0]
      @backing[filename] = InteractableSurfaceBackedPallette.new(filename, config[1], config[2])
    }
  end

  def []=(key, value)
    @backing[value.filename][key] = value
  end

  def [](key)
    @backing.each {|k,v|
      r = v[key]
      return r unless r.nil?
    }
    nil
  end

end

class InteractableSurfaceBackedPallette < SurfaceBackedPallette

  def [](key)
    entry = @pal[key]
    return nil if entry.nil?
    s = Surface.new([@tile_x,@tile_y])
    @surface.blit(s, [0,0], [entry.offsets[0] * @tile_x, entry.offsets[1] * @tile_y, @tile_x, @tile_y] )
    ISBPResult.new(s, entry.actionable, self)
  end
end

class EventHelper
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

class ItemAttributes < CharacterAttributes
  def self.none
    ItemAttributes.new(0,0,0,0,0,0,0,0)
  end
end

class ItemState < CharacterState
  
end

class GameItemFactory
  def self.potion
    GameItem.new("potion", ItemState.new( ItemAttributes.none, 0, 10 ))
  end

  def self.antidote
    GameItem.new("antidote", ItemState.new(ItemAttributes.none, 0, 20 ))
  end

  def self.sword
    GameItem.new("sword", ItemState.new(ItemAttributes.new(0,0,1,0,0,0,0,0), 0, 20 ))
  end

end

class EquippableGameItem
  def equippable?
    true
  end
  def consumeable?
    false
  end

end
class GameItem
  attr_reader :state, :name
  alias_method :effects,:state
  def initialize(name, state)
    @name = name
    @state = state
  end

  def to_s
    @name
  end

  def equippable?
    false
  end

  def consumeable?
    true
  end

end

class GameInternalsFactory
  def make_screen
    #@screen = Screen.open( [640, 480] )
    screen = Screen.new([@@SCREEN_X, @@SCREEN_Y])
    screen.title = @@GAME_TITLE
    screen
  end
  def make_clock
    clock = Clock.new()
    clock.target_framerate = 50
    clock.calibrate
    clock.enable_tick_events
    clock
  end

  def make_queue
    queue = EventQueue.new()
    queue.enable_new_style_events

    queue.ignore = [MouseMoved]
    queue
  end

  def make_game_layers(screen, game)
    GameLayers.new(make_dialog_layer(screen, game), make_menu_layer(screen,game), make_battle_layer(screen, game), make_notifications_layer(screen, game))
  end
  def make_battle_layer(screen, game)
    BattleLayer.new(screen, game)
  end
  def make_notifications_layer(screen, game)
    NotificationsLayer.new(screen, game)
  end
  def make_dialog_layer(screen, game)
    DialogLayer.new(screen, game)
  end
  def make_menu_layer(screen,game)
    MenuLayer.new(screen,game)
  end
  def make_universe(worldstates, layers, sound_effects, game)
    Universe.new(0, worldstates , layers, sound_effects, game)
  end
  def make_hud(screen, player, universe)
    Hud.new :screen => screen, :player => player, :universe => universe 
  end
  def make_player(screen, universe)
    #@player = Ship.new( @screen.w/2, @screen.h/2, @topomap, pallette, @terrainmap, terrain_pallette, @interactmap, interaction_pallette, @bgsurface )
    hero = Hero.new("hero",  SwungWorldWeapon.new(interaction_pallette), @@HERO_START_BATTLE_PTS, @@HERO_BATTLE_PTS_RATE, CharacterAttribution.new(
        CharacterState.new(CharacterAttributes.new(5, 5, 1, 0, 0, 0, 0, 0)),
        EquipmentHolder.new))
    hero2 = Hero.new("cohort", ShotWorldWeapon.new(interaction_pallette), @@HERO_START_BATTLE_PTS, @@HERO_BATTLE_PTS_RATE, CharacterAttribution.new(
        CharacterState.new(CharacterAttributes.new(5, 5, 1, 0, 0, 0, 0, 0)),
        EquipmentHolder.new))
    party_inventory = Inventory.new(255) #TODO revisit inventory -- should it have a maximum? 
    party_inventory.add_item(1, GameItemFactory.potion)
    party_inventory.add_item(1, GameItemFactory.antidote) #TODO how to model status effects
    party_inventory.add_item(1, GameItemFactory.sword) #TODO how to model status effects
    party = Party.new([hero, hero2], party_inventory)
    hero_x_dim = 48
    hero_y_dim = 64
    player_file = "Charactern8.png"
    ssx = screen.w/2
    ssy = screen.h/2
    player = Player.new(ssx, ssy , universe, party, player_file, hero_x_dim, hero_y_dim , ssx, ssy )

    player
    # Make event hook to pass all events to @player#handle().
  end
  def make_world1
    bgm = BackgroundMusic.new("bonobo-time_is_the_enemy.mp3")
    WorldStateFactory.build_world_state("world1_bg","world1_interaction", pallette, interaction_pallette, @@BGX, @@BGY, [], bgm)
  end

  def make_monster(player,universe)
    monster_inv = Inventory.new(255)
    monster_inv.add_item(1, GameItemFactory.potion)
    monattrib = CharacterAttribution.new(
      CharacterState.new(CharacterAttributes.new(3, 0, 1, 0, 0, 0, 0, 0)),
      EquipmentHolder.new)
    monai = ArtificialIntelligence.new(RepeatingPathFollower.new("DRUL", 80), BattleStrategy.new([BattleTactic.new("Enemy: Any -> Attack")]))
    Monster.new(player,universe,"monster.png", 400,660, @@MONSTER_X, @@MONSTER_Y, monster_inv, monattrib, monai)
  end

  def make_npc(player, universe)
    npcattrib = CharacterAttribution.new(
        CharacterState.new(CharacterAttributes.new(3, 0, 0, 0, 0, 0, 0, 0)),
        EquipmentHolder.new)
    npcai = ArtificialIntelligence.new(RepeatingPathFollower.new("LURD", 80), nil) #TODO maybe make a noop battle strategy just in case?
    #npcai = StaticPathFollower.new
    TalkingNPC.new(player, universe, "i am an npc", "gogo-npc.png", 600, 200,48,64, Inventory.new(255), npcattrib, npcai)
  end

  def make_world2
    WorldStateFactory.build_world_state("world2_bg","world2_interaction", pallette_160,  interaction_pallette_160, @@BGX, @@BGY, [], BackgroundMusic.new("bonobo-gypsy.mp3"))
  end
  def make_world3
    WorldStateFactory.build_world_state("world3_bg","world3_interaction", pallette,  interaction_pallette, @@BGX, @@BGY, [], BackgroundMusic.new("bonobo-gypsy.mp3"))
  end

  def make_event_hooks(game, always_on_hooks, menu_killed_hooks, menu_active_hooks, battle_hooks)
    event_helper = EventHelper.new(game, always_on_hooks, menu_killed_hooks, menu_active_hooks, battle_hooks)
    event_helper
  end


  def make_sound_effects
    SoundEffectSet.new(["battle-start.ogg", "laser.ogg", "warp.ogg", "treasure-open.ogg"])
  end

  def tile(color)
    s = Surface.new([160,160])
    s.fill(color)
    s
  end
  
  def interaction_pallette
    pal = CompositeInteractableSurfaceBackedPallette.new([["treasure-boxes.png", 32,32], ["weapons-32x32.png", 32,32]])
#XXX note mixing sizes in a composite does not work well, ..
    pal['O'] = CISBPEntry.new(["treasure-boxes.png",4,7],OpenTreasure.new("O"))
    pal['T'] = CISBPEntry.new(["treasure-boxes.png",4,4],Treasure.new(GameItemFactory.potion))
    pal['E'] = CISBPEntry.new(["weapons-32x32.png", 1,0],Treasure.new(GameItemFactory.sword))
    pal['F'] = CISBPEntry.new(["treasure-boxes.png",4,4],Treasure.new(GameItemFactory.sword))
    pal['m'] = CISBPEntry.new(["treasure-boxes.png",1,1],WarpPoint.new(1, 120, 700))

    pal['w'] = CISBPEntry.new(["treasure-boxes.png",1,1],WarpPoint.new(1, 1020, 700))
#    pal['W'] = ISBPEntry.new([1,1],WarpPoint.new(0, 1200, 880))

    pal
  end
  def interaction_pallette_160
    pal = InteractableSurfaceBackedPallette.new("treasure-boxes-160.png", 160,160)

    pal['O'] = ISBPEntry.new([4,7],OpenTreasure.new("O"))
    pal['1'] = ISBPEntry.new([4,4],Treasure.new(GameItemFactory.potion))
    pal['2'] = ISBPEntry.new([4,4],Treasure.new(GameItemFactory.antidote))
    pal['3'] = ISBPEntry.new([4,4],Treasure.new(GameItemFactory.potion))
    pal['J'] = ISBPEntry.new([1,1],WarpPoint.new(2, 120, 700))
    pal['w'] = ISBPEntry.new([1,1],WarpPoint.new(1, 1020, 700))
    pal['W'] = ISBPEntry.new([1,1],WarpPoint.new(0, 1200, 880))

    pal

  end
  def pallette
    pal = SurfaceBackedPallette.new("scaled-background-20x20.png", 20, 20)
    pal['G'] = SBPEntry.new([1,4], false)
    pal['M'] = SBPEntry.new([0,2], true)
    pal['g'] = SBPEntry.new([0,6], false)
    pal['O'] = SBPEntry.new([1,3], true) #TODO this should not be open treasure
    pal['T'] = SBPEntry.new([1,3], true) #TODO this should not be treasure
    pal['w'] = SBPEntry.new([0,5], false) #TODO this should not be warp
    pal['W'] = SBPEntry.new([0,5], false) #TODO this should not be warp
    pal

  end
  def pallette_160
    pal = Pallette.new(tile(:blue))
    pal['O'] = JsonLoadableSurface.new("open-treasure-on-grass-bg-160.png", true)
    pal['T'] = JsonLoadableSurface.new("treasure-on-grass-bg-160.png", true)
    pal['w'] = JsonLoadableSurface.new("water-bg-160.png", true)
    pal['W'] = JsonLoadableSurface.new("town-on-grass-bg-160.png", false)
    pal['M'] = JsonLoadableSurface.new("mountain-bg-160.png", true)
    pal['G'] = JsonLoadableSurface.new("grass-bg-160.png", false)
    pal['g'] = JsonLoadableSurface.new("real-grass-bg-160.png", false)
    pal
  end



end

class Game
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
    @universe.toggle_bg_music

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

  def battle_begun(universe, player)
    toggle_battle_hooks(false)
  end
  def battle_completed
    toggle_battle_hooks(true)
    @player.clear_keys
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
    :reset_menu_positions, :add_notification, :toggle_bg_music, :current_battle_participant_offset

  def_delegators :@event_helper, :non_menu_hooks, :rebuild_event_hooks
  def_delegator :@event_helper, :menu_active_hooks, :menu_hooks
  def_delegator :@event_helper, :battle_active_hooks, :battle_hooks
  def_delegator :@event_helper, :non_menu_hooks, :non_battle_hooks

  def_delegator :@player, :update_tile_coords, :update_player_tile_coords
  def_delegators :@player, :party_members, :inventory_info, :inventory_at, 
    :inventory, :use_weapon


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
  def interact_with_facing(event)
    @player.interact_with_facing(self)
  end
  def battle_confirm
    battle_layer.enter_current_cursor_location(self)
  end
  def capture_ss(event)
    #TODO this does not work, find a different way to dump screen data
    #@screen.savebmp("screenshot.bmp")

    SDL.SaveBMP_RW("screenshot.bmp",@screen, 0)
  end
  def quit
    puts "Quitting!"
    throw :quit
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

Game.new.go

Rubygame.quit()