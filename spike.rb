#!/bin/env ruby

# One way of making an object start and stop moving gradually:
# make user input affect acceleration, not velocity.

require 'rubygems'

require 'rubygame'
require 'json'

require 'lib/font_loader'
require 'lib/topo_map'
require 'lib/hud'
require 'lib/inventory'
require 'lib/hero'

# Include these modules so we can type "Surface" instead of
# "Rubygame::Surface", etc. Purely for convenience/readability.

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
@@MENU_LINE_SPACING = 25
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
@@OPEN_TREASURE = 'O'
@@MONSTER_X = 32
@@MONSTER_Y = 32

class Universe
  attr_reader :worlds, :current_world, :dialog_layer, :menu_layer, :battle_layer, :current_world_idx

  def initialize(current_world_idx, worlds, dialog_layer=nil, menu_layer=nil, battle_layer=nil)
    raise "must have at least one world" if worlds.empty?
    @current_world = worlds[current_world_idx]
    @current_world_idx = current_world_idx
    @worlds = worlds
    @dialog_layer = dialog_layer
    @menu_layer = menu_layer
    @battle_layer = battle_layer
    
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


  def to_json(*a)
    {
      'json_class' => self.class.name,
      'data' => [ @current_world_idx, @worlds]
    }.to_json(*a)
  end
  def self.json_create(o)
    new(*o['data'])
  end

end


class WorldState
  attr_reader :topo_map, :topo_pallette, :terrain_map, :terrain_pallette,
              :interaction_map, :interaction_pallette, :npcs,
              :background_surface
            
  def initialize(topomap, topopal, terrainmap, terrainpal, interactmap, interactpal, npcs, bgsurface)
    @topo_map = topomap
    @topo_pallette = topopal
    @terrain_map = terrainmap
    @terrain_pallette = terrainpal
    @interaction_map = interactmap
    @interaction_pallette = interactpal
    @npcs = npcs
    @background_surface = bgsurface
    
    raise "topomap" if @topo_map.nil?
    raise "topopal" if @topo_pallette.nil?
    raise "bg surf" if @background_surface.nil?
    topomap.blit_to(topopal, bgsurface)
  end

  def reblit_background
    @topo_map.blit_to(@topo_pallette, @background_surface)
  end

  def delete_monster(monster)
    @npcs -= [monster]
  end

  def to_json(*a)
    {
      'json_class' => self.class.name,
      'data' => [ @topo_map, @topo_pallette, @terrain_map, @terrain_pallette,
            @interaction_map, @interaction_pallette, @npcs, @background_surface] #TODO reconsider terrain/etc loading
    }.to_json(*a)
  end
  def self.json_create(o)
    new(*o['data'])
  end



end

class KeyHolder
  def initialize
    @keys = []
  end
  def include?(other)
    @keys.include?(other)
  end
  def empty?
    @keys.empty?
  end

  def delete_key(key)
    @keys -= [key]
  end
  def add_key(key)
    @keys += [key]
  end
  
end
class AlwaysDownMonsterKeyHolder < KeyHolder
  @@DOWNKEY = :always_down
  def initialize(key=@@DOWNKEY)
    super()
    add_key(key)
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
    tilex = @universe.current_world.topo_map.x_offset_for_world(px)
    tiley = @universe.current_world.topo_map.y_offset_for_world(py)
    this_tile_interacts = @universe.current_world.interaction_pallette[@universe.current_world.interaction_map.data_at(tilex,tiley)]
    facing_tile_interacts = false

    if this_tile_interacts
      puts "you can interact with the current tile"
      this_tile_interacts.activate(@player, @universe.current_world, tilex, tiley)
      return
    end

    if @facing == :down
      facing_tilex = tilex
      facing_tiley = tiley + 1
      facing_tile_dist = (@universe.current_world.interaction_map.top_side(tiley + 1) - py).abs
    end
    if @facing == :up
      facing_tilex = tilex
      facing_tiley = tiley - 1
      facing_tile_dist = (@universe.current_world.interaction_map.bottom_side(tiley - 1) - py).abs
    end
    if @facing == :left
      facing_tilex = tilex - 1
      facing_tiley = tiley
      facing_tile_dist = (@universe.current_world.interaction_map.right_side(tilex - 1) - px).abs
    end
    if @facing == :right
      facing_tilex = tilex + 1
      facing_tiley = tiley
      facing_tile_dist = (@universe.current_world.interaction_map.left_side(tilex + 1) - px).abs
    end

    facing_tile_interacts = @universe.current_world.interaction_pallette[@universe.current_world.interaction_map.data_at(facing_tilex, facing_tiley)]
    facing_tile_close_enough = facing_tile_dist < @@INTERACTION_DISTANCE_THRESHOLD

    if facing_tile_close_enough and facing_tile_interacts
      puts "you can interact with the facing tile in the #{@facing} direction, it is at #{facing_tilex} #{facing_tiley}"
      facing_tile_interacts.activate(@player, @universe.current_world, facing_tilex, facing_tiley) #@interactionmap, facing_tilex, facing_tiley, @bgsurface, @topomap, @topo_pallette
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
class CoordinateHelper
  attr_accessor :px, :py

  def initialize(px,py, key,universe, hero_x_dim, hero_y_dim)
     @hero_x_dim, @hero_y_dim =  hero_x_dim, hero_y_dim
    @universe = universe
    @keys = key
    @px, @py = px, py # Current Position
    @vx, @vy = 0, 0 # Current Velocity
    @ax, @ay = 0, 0 # Current Acceleration
    @max_speed = 400.0 # Max speed on an axis
    @accel = 1200.0 # Max Acceleration on an axis
    @slowdown = 800.0 # Deceleration when not accelerating
  end

  def update_tile_coords
    @mintilex = @universe.current_world.topo_map.x_offset_for_world(@px - x_ext)
    @maxtilex = @universe.current_world.topo_map.x_offset_for_world(@px + x_ext)
    @mintiley = @universe.current_world.topo_map.y_offset_for_world(@py - y_ext)
    @maxtiley = @universe.current_world.topo_map.y_offset_for_world(@py + y_ext)
  end
  def x_ext
    @hero_x_dim/2
  end
  def y_ext
    @hero_y_dim/2
  end
  # Update the acceleration based on what keys are pressed.
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


  # Update the velocity based on the acceleration and the time since
  # last update.
  def update_vel( dt )
    @vx = update_vel_axis( @vx, @ax, dt )
    @vy = update_vel_axis( @vy, @ay, dt )
  end


  # Calculate the velocity for one axis.
  # v = current velocity on that axis (e.g. @vx)
  # a = current acceleration on that axis (e.g. @ax)
  #
  # Returns what the new velocity (@vx) should be.
  #
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

  def clamp_to_world_dimensions

    minx = @px - x_ext
    maxx = @px + x_ext
    miny = @py - y_ext
    maxy = @py + y_ext
    @px = x_ext if minx < 0
    @px = @@BGX - x_ext if maxx > @@BGX

    @py = y_ext if miny < 0
    @py = @@BGY - y_ext if maxy > @@BGY
  end

  def clamp_to_tile_restrictions_on_y(tp, new_mintilex, new_mintiley, new_maxtilex, new_maxtiley)
    rv = false

    if new_mintiley != @mintiley
      bottom_right = @universe.current_world.terrain_map.data_at(new_maxtilex, new_mintiley)
      bottom_left = @universe.current_world.terrain_map.data_at(new_mintilex, new_mintiley)

      unless tp[bottom_left] and tp[bottom_right]
        rv = true
      end
    end
    if new_maxtiley != @maxtiley

      top_right = @universe.current_world.terrain_map.data_at(new_maxtilex, new_maxtiley)
      top_left = @universe.current_world.terrain_map.data_at(new_mintilex, new_maxtiley)

      unless tp[top_left] and tp[top_right]
        rv = true
      end

    end
    rv
  end
  def clamp_to_tile_restrictions_on_x(tp, new_mintilex, new_mintiley, new_maxtilex, new_maxtiley)
    rv = false
    
    if new_mintilex != @mintilex
      bottom_left = @universe.current_world.terrain_map.data_at(new_mintilex, new_mintiley)
      top_left = @universe.current_world.terrain_map.data_at(new_mintilex, new_maxtiley)
      unless tp[bottom_left] and tp[top_left]
        rv = true
      end
    end

    if new_maxtilex != @maxtilex
      bottom_right = @universe.current_world.terrain_map.data_at(new_maxtilex, new_mintiley)
      top_right = @universe.current_world.terrain_map.data_at(new_maxtilex, new_maxtiley)

      unless tp[bottom_right] and tp[top_right]
        rv = true
      end
    end

    rv
  end

  

  def update_pos( dt )
    dx = @vx * dt
    dy = @vy * dt
    @px += dx
    @py += dy

    clamp_to_world_dimensions

    tp = @universe.current_world.terrain_pallette
    new_mintilex = @universe.current_world.topo_map.x_offset_for_world(@px - x_ext)
    new_maxtilex = @universe.current_world.topo_map.x_offset_for_world(@px + x_ext)
    new_mintiley = @universe.current_world.topo_map.y_offset_for_world(@py - y_ext)
    new_maxtiley = @universe.current_world.topo_map.y_offset_for_world(@py + y_ext)

    @px -= dx if clamp_to_tile_restrictions_on_x(tp, new_mintilex, new_mintiley, new_maxtilex, new_maxtiley)
    @py -= dy if clamp_to_tile_restrictions_on_y(tp, new_mintilex, new_mintiley, new_maxtilex, new_maxtiley)

    update_tile_coords

    # @rect.center = [@px, @py]
  end


end
class AnimatedSpriteHelper
  attr_reader :image, :rect, :px, :py

  def initialize(filename, px, py, avatar_x_dim, avatar_y_dim)
    @all_char_postures = Surface.load(filename)
    @all_char_postures.colorkey = @all_char_postures.get_at(0,0)
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
    text_lines.each_with_index do |text, index|
      text_surface = @font.render text.to_s, true, [16,222,16]
      text_surface.blit @layer, [conf.xc + conf.xf * index,conf.yc + conf.yf * index]
    end

  end

end
class MenuHelper
  def initialize(screen, layer,text_helper, sections, cursor_x, cursor_y, cursor_main_color=:blue, cursor_inactive_color=:white)
    @layer = layer
    @text_rendering_helper = text_helper
    @menu_sections = sections
    @text_lines = @menu_sections.collect{|ms|ms.text}
    @cursor_position = 0
    @section_position = 0
    @cursor = Surface.new([cursor_x, cursor_y])
    @cursor_main_color = cursor_main_color
    @cursor_inactive_color = cursor_inactive_color
    @cursor.fill(@cursor_inactive_color)
    @show_section = false
    @screen = screen
  end

  def color_for_current_section_cursor
    @cursor_main_color
  end

  def active_section
    @menu_sections[@cursor_position]
  end

  def move_cursor_down
    if @show_section
      @section_position = (@section_position + 1) % active_section.content.size
    else
      @cursor_position = (@cursor_position + 1) % @text_lines.size
    end
  end
  def move_cursor_up
    if @show_section
      @section_position = (@section_position - 1) % active_section.content.size
    else
      @cursor_position = (@cursor_position - 1) % @text_lines.size
    end
  end
  def enter_current_cursor_location(game)
    if @show_section
      active_section.content[@section_position].activate(@cursor_position, game, @section_position)
    else
      @show_section = true
    end

  end
  def cancel_action
    @show_section = false
    @section_position = 0
  end

  def draw(menu_layer_config)
    @text_rendering_helper.render_lines_to_layer( @text_lines, menu_layer_config.main_menu_text)
    @cursor.fill(color_for_current_section_cursor)
    if @show_section
      @text_rendering_helper.render_lines_to_layer(active_section.text_contents, menu_layer_config.section_menu_text)
      conf = menu_layer_config.in_section_cursor
      @cursor.blit(@layer, [conf.xc + conf.xf * @section_position, conf.yc + conf.yf * @section_position])
    else
      conf = menu_layer_config.main_cursor
      @cursor.blit(@layer, [conf.xc + conf.xf * @cursor_position, conf.yc + conf.yf * @cursor_position])
    end
    @layer.blit(
      @screen, menu_layer_config.layer_inset_on_screen)

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
  attr_reader :members, :inventory
  def initialize(members, inventory)
    @members = members
    @inventory = inventory
  end
  def add_item(qty, item)
    @inventory.add_item(qty, item)
  end

  def collect
    @members.collect {|member| yield member}
  end

  def add_readiness(pts)
    @members.each {|member| member.add_readiness(pts) }
  end
  def gain_experience(pts)
    @members.each {|member| member.gain_experience(pts) }
  end

  def gain_inventory(inventory)
    @inventory.gain_inventory(inventory)
  end

  def to_json(*a)
    {
      'json_class' => self.class.name,
      'data' => [ @members, @inventory]
    }.to_json(*a)
  end
  def self.json_create(o)
    new(*o['data'])
  end


end

class Player
  include Sprites::Sprite
  include EventHandler::HasEventHandler
  
  attr_accessor :universe, :party

  def to_json(*a)
    puts "px,py: #{px},#{py}"
    {
      'json_class' => self.class.name,
      'data' => [ @coordinate_helper.px, @coordinate_helper.py, @universe, @party, @filename,@hero_x_dim, @hero_y_dim, @animated_sprite_helper.px, @animated_sprite_helper.py]
    }.to_json(*a)
  end
  def self.json_create(o)
    new(*o['data'])
  end

  def image
    @animated_sprite_helper.image
  end
  def rect
    @animated_sprite_helper.rect
  end

  def inventory
    @party.inventory
  end

  def gain_inventory(inventory)
    @party.gain_inventory(inventory)
  end
  def gain_experience(pts)
    @party.gain_experience(pts)
  end

  def add_readiness(pts)
    @party.add_readiness(pts)
  end

  def add_inventory(qty, item)
    @party.add_item(qty, item)
  end

  def px
    @coordinate_helper.px
  end
  def py
    @coordinate_helper.py
  end


  attr_reader :party, :universe, :filename, :hero_x_dim, :hero_y_dim
  def initialize( px, py,  universe, party, filename, hx, hy, sx, sy)
    @universe = universe
    @filename = filename
    @hero_x_dim = hx
    @hero_y_dim = hy
    @interaction_helper = InteractionHelper.new(self, @universe)
    @keys = KeyHolder.new
    @coordinate_helper = CoordinateHelper.new(px, py, @keys, @universe, @hero_x_dim, @hero_y_dim)
    @animation_helper = AnimationHelper.new(@keys)
    @coordinate_helper.update_tile_coords
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

  private

  # Add it to the list of keys being pressed.
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


  # Remove it from the list of keys being pressed.
  def key_released( event )
    @keys.delete_key(event.key)
    
  end

  # Update the ship state. Called once per frame.
  def update( event )
    dt = event.seconds # Time since last update
    @animation_helper.update_animation(dt) { |frame| @animated_sprite_helper.replace_avatar(frame) }
    @coordinate_helper.update_accel
    @coordinate_helper.update_vel( dt )
    @coordinate_helper.update_pos( dt )
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
  def initialize(name)
    @name = name
  end

  def activate(player, worldstate, tilex, tiley)
    worldstate.interaction_map.update(tilex, tiley, @@OPEN_TREASURE)
    #XXX this is not graceful, don't have to reblit the whole thing

    worldstate.topo_map.update(tilex, tiley, @@OPEN_TREASURE)
    worldstate.reblit_background
    
    puts "also, give it to the player"
    player.add_inventory(1, @name)
  end

  def to_json(*a)
    {
      'json_class' => self.class.name,
      'data' => [ @name] #TODO reconsider terrain/etc loading
    }.to_json(*a)
  end

  def self.json_create(o)
    new(*o['data'])
  end

end
class OpenTreasure < Treasure
  def activate( player, worldstate, tilex, tiley)
    puts "Nothing to do, already opened"
  end
end

class WarpPoint
  attr_accessor :destination
  def initialize(dest_index)
    @destination = dest_index
  end

  def activate(player, worldstate, tilex, tiley)
    uni = player.universe
    
    puts "warp from  #{worldstate} to #{uni.world_by_index(@destination)}"
    uni.set_current_world_by_index(@destination)
  end

  def to_json(*a)
    {
      'json_class' => self.class.name,
      'data' => [ @destination] #TODO reconsider terrain/etc loading
    }.to_json(*a)
  end
  def self.json_create(o)
    new(*o['data'])
  end



end

class AbstractLayer

  include FontLoader #TODO unify resource loading
  attr_accessor :active

  

  def initialize(screen, layer_width, layer_height)
    @screen = screen
    @active = false
    @layer = Surface.new([layer_width, layer_height])
    @font = load_font("FreeSans.ttf")

  end

  def toggle_activity
    @active = !@active
  end

  alias_method :active?, :active
  alias_method :visible, :active
  alias_method :toggle_visibility, :toggle_activity
end
class DialogLayer < AbstractLayer
  attr_accessor :visible, :text
  include FontLoader #TODO unify resource loading

  def initialize(screen)
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
    puts "dialog done"
  end
  
end
class MenuLayer < AbstractLayer

  include FontLoader #TODO unify resource loading
  attr_accessor :active

  alias_method :active?, :active
  alias_method :visible, :active
  alias_method :toggle_visibility, :toggle_activity

  def initialize(screen)
    super(screen, (screen.w) - 2*@@MENU_LAYER_INSET, (screen.h) - 2*@@MENU_LAYER_INSET)
    @layer.fill(:red)
    @layer.alpha = 192
    @text_rendering_helper = TextRenderingHelper.new(@layer, @font)
    sections = [MenuSection.new("Status", [MenuAction.new("status info line 1"), MenuAction.new("status info line 2")]),
          MenuSection.new("Inventory", [MenuAction.new("inventory contents:"), MenuAction.new("TODO real data")]),
      MenuSection.new("Equip", [MenuAction.new("head equipment:"), MenuAction.new("arm equipment: "), MenuAction.new("etc")]),
      MenuSection.new("Save", [SaveAction.new("Slot 1")]),
      MenuSection.new("Load", [LoadAction.new("Slot 1")])
      ]
    @menu_helper = MenuHelper.new(screen, @layer, @text_rendering_helper, sections, @@MENU_LINE_SPACING,@@MENU_LINE_SPACING)
  end


  def menu_layer_config

    mlc = MenuLayerConfig.new
    mlc.main_menu_text = TextRenderingConfig.new(@@MENU_TEXT_INSET, 0, @@MENU_TEXT_INSET, @@MENU_LINE_SPACING)
    mlc.section_menu_text = TextRenderingConfig.new(3 * @@MENU_TEXT_INSET + @@MENU_TEXT_WIDTH + @@MENU_LINE_SPACING, 0, @@MENU_TEXT_INSET, @@MENU_LINE_SPACING)
    mlc.in_section_cursor = TextRenderingConfig.new(2 * @@MENU_TEXT_INSET + 4*@@MENU_TEXT_WIDTH, 0, @@MENU_TEXT_INSET, @@MENU_LINE_SPACING)
    mlc.main_cursor = TextRenderingConfig.new(2 * @@MENU_TEXT_INSET + @@MENU_TEXT_WIDTH, 0, @@MENU_TEXT_INSET, @@MENU_LINE_SPACING)
    mlc.layer_inset_on_screen = [@@MENU_LAYER_INSET,@@MENU_LAYER_INSET]
    mlc
  end

  def draw()
    @layer.fill(:red)
    @menu_helper.draw(menu_layer_config)
  end

  def enter_current_cursor_location(game)
    @menu_helper.enter_current_cursor_location(game)
  end
  def move_cursor_down
    @menu_helper.move_cursor_down
  end
  def move_cursor_up
    @menu_helper.move_cursor_up
  end

  def cancel_action
    @menu_helper.cancel_action
  end

end
class BattleLayer < AbstractLayer
  attr_reader :battle
  include EventHandler::HasEventHandler
  def initialize(screen)
    super(screen, screen.w - 50, screen.h - 50)
    @layer.fill(:orange)
    @text_rendering_helper = TextRenderingHelper.new(@layer, @font)
    @battle = nil
    @menu_helper = nil
    sections = [MenuSection.new("Exp",[EndBattleAction.new("Confirm", self)]),
                MenuSection.new("Items", [EndBattleAction.new("Confirm", self)])]
    @end_of_battle_menu_helper = MenuHelper.new(screen, @layer, @text_rendering_helper, sections, @@MENU_LINE_SPACING,@@MENU_LINE_SPACING)
    make_magic_hooks({ClockTicked => :update})
  end
  def update( event )
    return unless @battle
    dt = event.seconds # Time since last update
    @battle.accumulate_readiness(dt)
  end
  def start_battle(game, universe, player, monster)
    @active = true
    puts "starting battle, bound field value is #{self.active?}"
    @battle = Battle.new(game, universe, player, monster, self)
    sections = player.party.collect {|hero|  HeroMenuSection.new(hero, [AttackAction.new("Attack", self), ItemAction.new("Item")])}
    @menu_helper = BattleMenuHelper.new(@battle, @screen, @layer, @text_rendering_helper, sections, @@MENU_LINE_SPACING,@@MENU_LINE_SPACING)
  end
  def end_battle
    @active = false
    @battle.end_battle
  end
  def menu_layer_config

    mlc = MenuLayerConfig.new
    mlc.main_menu_text = TextRenderingConfig.new(@@MENU_TEXT_INSET, @@MENU_TEXT_WIDTH, @layer.h - 50, 0)
    mlc.section_menu_text = TextRenderingConfig.new(@@MENU_TEXT_INSET, @@MENU_TEXT_WIDTH, @layer.h - 150, 0)
    mlc.in_section_cursor = TextRenderingConfig.new(@@MENU_TEXT_INSET , @@MENU_TEXT_WIDTH, @layer.h - 200, 0)
    mlc.main_cursor = TextRenderingConfig.new(@@MENU_TEXT_INSET , @@MENU_TEXT_WIDTH, @layer.h - 100, 0)
    mlc.layer_inset_on_screen = [@@LAYER_INSET,@@LAYER_INSET]
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
      @end_of_battle_menu_helper.draw(end_battle_menu_layer_config)
    else
      @battle.monster.draw_to(@layer)
      @menu_helper.draw(menu_layer_config)
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
    if @battle.over?
      @end_of_battle_menu_helper.move_cursor_down
    else
      @menu_helper.move_cursor_down
    end

  end
  def move_cursor_up
    if @battle.over?
      @end_of_battle_menu_helper.move_cursor_up
    else
      @menu_helper.move_cursor_up
    end
  end

  def cancel_action
    if @battle.over?
      @end_of_battle_menu_helper.cancel_action
    else
      @menu_helper.cancel_action
    end
  end

end

class MenuSection

  attr_reader :text, :content
  def initialize(text, content)
    @text = text
    @content = content
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
end
class MenuLayerConfig
  attr_accessor :main_menu_text, :section_menu_text, :in_section_cursor, :main_cursor, :layer_inset_on_screen
end

class MenuAction
  attr_reader :text
  def initialize(text, action_cost=@@DEFAULT_ACTION_COST)
    @text = text
    @action_cost = action_cost
  end

  def activate(main_menu_idx, game, submenu_idx)
    puts "This is a no-op action: #{@text}"
  end
end
class AttackAction < MenuAction
  def initialize(text, battle_layer)
    super(text, @@ATTACK_ACTION_COST)
    @battle_layer = battle_layer

  end
  def activate(party_member_index, game, submenu_idx)
    battle = @battle_layer.battle
    
    hero = battle.player.party.members[party_member_index]
    battle.monster.take_damage(hero.damage)
    hero.consume_readiness(@action_cost)
    puts "hero #{hero} hit #{battle.monster} for #{hero.damage}"
    puts "hero #{hero} killed #{battle.monster}" if battle.monster.dead?
  end
end
class ItemAction < MenuAction
  def activate(party_member_index, game, submenu_idx)
    battle = @battle_layer.battle
    puts "TODO itemaction"


  end

end
class EndBattleAction < MenuAction
  def initialize(text, battle_layer)
    super(text)
    @battle_layer = battle_layer
  end

  def activate(menu_idx, game, submenu_idx)
    puts "ending battle from menu #{menu_idx}"
    @battle_layer.end_battle
  end
end

class SaveLoadAction < MenuAction
  def save_slot(idx)
    "save-slot-#{idx}.json"
  end
end

class SaveAction < SaveLoadAction
  def activate(menu_idx, game, submenu_idx)
    json = JSON.generate(game.player)

    save_file = File.open(save_slot(submenu_idx), "w")
    save_file.puts json
    save_file.close
    puts "saving to slot #{submenu_idx}, json data is: "
    puts "player was at #{game.player.px} and #{game.player.py} at save time"
    puts json
  end
end


class ReloaderHelper
  def replace(game, json_player)
    puts "player is at #{game.player.px} and #{game.player.py} at load time"
    uni = json_player.universe
    orig_uni = game.universe
    universe = Universe.new(uni.current_world_idx, uni.worlds, orig_uni.dialog_layer, orig_uni.menu_layer, orig_uni.battle_layer )

    puts "universe has current world: #{universe.current_world_idx}"
    universe.reblit_backgrounds
    player = Player.new(json_player.px, json_player.py,  universe, json_player.party, json_player.filename, json_player.hero_x_dim, json_player.hero_y_dim, game.screen.w/2, game.screen.h/2)

    game.universe = universe
    game.player = player
    game.remove_all_hooks
    game.make_event_hooks
    game.universe.menu_layer.toggle_activity
    game.make_hud
  end
end

class LoadAction < SaveLoadAction
  def activate(menu_idx, game, submenu_idx)

    puts "load from #{save_slot(submenu_idx)}"
    data = IO.readlines(save_slot(submenu_idx))
    rebuilt = JSON.parse(data.join(" "))
    puts "got rebuilt: #{rebuilt.class} "
    ReloaderHelper.new.replace(game, rebuilt)
  end
end
class Monster

  include Sprites::Sprite
  include EventHandler::HasEventHandler
  def px
    @animated_sprite_helper.px
  end
  def py
    @animated_sprite_helper.py
  end

  def add_readiness(pts)
    @readiness_helper.add_readiness(pts)
  end
  attr_reader :experience, :inventory
  def initialize(filename, px, py, npc_x = @@MONSTER_X, npc_y = @@MONSTER_Y, inventory=Inventory.new(255), hp=3, exp=10)
    super()
    @npc_x = npc_x
    @npc_y = npc_y
    @filename = filename
    @animated_sprite_helper = AnimatedSpriteHelper.new(filename, px, py, @npc_x, @npc_y)
    @keys = AlwaysDownMonsterKeyHolder.new
    @animation_helper = AnimationHelper.new(@keys, 3)
    @readiness_helper = BattleReadinessHelper.new(@@MONSTER_START_BATTLE_PTS, @@MONSTER_BATTLE_PTS_RATE)
    @hp = hp
    @experience = exp
    @inventory = inventory
    make_magic_hooks(
      ClockTicked => :update
    )
  end

  def dead?
    @hp <= 0
  end



  def take_damage(damage)
    @hp -= damage
  end

  def draw(surface,x,y,sx,sy)
    tx = @animated_sprite_helper.px - x + sx/2
    ty = @animated_sprite_helper.py - y + sy/2
    @animated_sprite_helper.image.blit surface, [tx,ty,96,128]
  end

  def draw_to(layer)
    @animated_sprite_helper.image.blit layer, [0,0,96,128]

  end

  def update(event)
    dt = event.seconds # Time since last update
    @animation_helper.update_animation(dt) { |frame| @animated_sprite_helper.replace_avatar(frame) }

  end

  def distance_to(x,y)
    [(px - x).abs, (py - y).abs]
  end

  def nearby?(x,y, distx, disty)
    dist = distance_to(x,y)
    (dist[0] < distx) and (dist[1] < disty)
  end

  def interact(game, universe, player)
    game.battle_begun(universe,player)
    universe.battle_layer.start_battle(game, universe, player, self)
  end

  def to_json(*a)
    params = [ @filename, @animated_sprite_helper.px, @animated_sprite_helper.py, @npc_x, @npc_y, @inventory, @hp, @experience]
    {
      'json_class' => self.class.name,
      'data' => params
    }.to_json(*a)
  end

  def self.json_create(o)
    new(*o['data'])
  end



end
class TalkingNPC < Monster
  def initialize(text, filename, px, py, npc_x, npc_y, inv=nil, hp=0, exp=0)
    super(filename, px, py, npc_x, npc_y, inv, hp, exp)
    @text = text
  end

  def interact(game, universe, player)
    puts "display dialog '#{@text}' from #{self}"
    universe.dialog_layer.active = true
    universe.dialog_layer.text = @text
  end
  def to_json(*a)
    params = [ @text, @filename, @animated_sprite_helper.px, @animated_sprite_helper.py, @npc_x, @npc_y, @inventory, @hp, @experience]
    {
      'json_class' => self.class.name,
      'data' => params
    }.to_json(*a)
  end

  def self.json_create(o)
    new(*o['data'])
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

end

class Battle
  
  attr_reader :monster, :player
  def initialize(game, universe, player, monster, battle_layer)
    @game = game
    @player = player
    @monster = monster
    @universe = universe
  end

  def accumulate_readiness(dt)
    points = dt * @@READINESS_POINTS_PER_SECOND
    @player.add_readiness(points)
    @monster.add_readiness(points)
  end
  def party
    @player.party
  end

  def over?
    @monster.dead?
  end

  def end_battle
    @game.battle_completed
    @player.gain_experience(@monster.experience)
    puts "monster had #{@monster.inventory.keys.size} items"
    @player.gain_inventory(@monster.inventory)
    @universe.current_world.delete_monster(@monster)
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


  def to_json(*a)
    {
      'json_class' => self.class.name,
      'data' => [ @size] #TODO reconsider terrain/etc loading
    }.to_json(*a)
  end

  def self.json_create(o)
    new(*o['data'])
  end

end

class JsonLoadableSurface 
  def initialize(filename)
    @filename = filename
    @surface = Surface.load(filename)
  end

  def blit(layer, offset)
    @surface.blit(layer, offset)
  end

  def to_json(*a)
    {
      'json_class' => self.class.name,
      'data' => [ @filename] #TODO reconsider terrain/etc loading
    }.to_json(*a)
  end

  def self.json_create(o)
    new(*o['data'])
  end

end

class Game
  include EventHandler::HasEventHandler

  attr_accessor :player, :universe, :screen
  def initialize()
    make_screen
    make_clock
    make_queue
    
    @npc_hooks = []
    make_world1
    make_world2
    make_dialog_layer
    @npc_hooks.flatten
    make_menu_layer
    make_battle_layer
    make_universe
    make_player
    make_hud
    make_event_hooks
  end

  def make_battle_layer
    @battle_layer = BattleLayer.new(@screen)
    
  end
  def make_menu_layer
    @menu_layer = MenuLayer.new(@screen)
  end

  def make_hud
    @hud = Hud.new :screen => @screen, :player => @player, :topomap => @topomap
  end
  def make_world1

    bg_data = ['M','M','M','M','M','M','M','M',
               'M','G','G','G','G','G','G','M',
               'M','G','T','G','G','G','G','M',
               'M','G','G','G','G','G','G','M',
               'M','G','G','G','G','G','W','M',
               'M','M','M','M','M','M','M','M'
    ]
    terrain_data = [ '.','.','.','.','.','.','.','.',
                      '.','e','e','e','e','e','e','.',
                      '.','e','T','e','e','e','e','.',
                      '.','e','e','e','e','e','e','.',
                      '.','e','e','e','e','e','e','.',
                      '.','.','.','.','.','.','.','.'
    ]
    interaction_data = [ '.','.','.','.','.','.','.','.',
                         '.','.','.','.','.','.','.','.',
                         '.','.','T','.','.','.','.','.',
                         '.','.','.','.','.','.','.','.',
                         '.','.','.','.','.','.','w','.',
                         '.','.','.','.','.','.','.','.'
    ]

    terrainmap = TopoMap.new(8,6, @@BGX, @@BGY, terrain_data)
    topomap = TopoMap.new(8,6, @@BGX,@@BGY, bg_data)
    interactmap = TopoMap.new(8,6, @@BGX,@@BGY, interaction_data)

    bgsurface = JsonSurface.new([@@BGX,@@BGY])
    


    monster_inv = Inventory.new(255)
    monster_inv.add_item(1, "potion")
    @npcs = [TalkingNPC.new("i am an npc", "gogo-npc.png", 600, 200,48,64), Monster.new("monster.png", 400,660, @@MONSTER_X, @@MONSTER_Y, monster_inv)]

    @worldstate = WorldState.new(topomap, pallette, terrainmap, terrain_pallette, interactmap, interaction_pallette, @npcs, bgsurface)
  end
  def make_world2

    bg_data = ['M','M','M','G','G','G','M','M',
               'M','G','G','T','T','T','G','M',
               'M','G','G','G','G','G','G','w',
               'M','G','G','G','G','G','G','w',
               'M','G','G','G','G','G','W','w',
               'M','M','M','M','w','w','w','w'
    ]
    terrain_data = [  '.','.','.','e','e','e','.','.',
                      '.','e','e','T','T','T','e','.',
                      '.','e','e','e','e','e','e','.',
                      '.','e','e','e','e','e','e','.',
                      '.','e','e','e','e','e','e','.',
                      '.','.','.','.','.','.','.','.'
    ]
    interaction_data = [ '.','.','.','.','.','.','.','.',
                         '.','.','.','1','2','3','.','.',
                         '.','.','.','.','.','.','.','.',
                         '.','.','.','.','.','.','.','.',
                         '.','.','.','.','.','.','W','.',
                         '.','.','.','.','.','.','.','.'
    ]
    
    terrainmap = TopoMap.new(8,6, @@BGX, @@BGY, terrain_data)
    topomap = TopoMap.new(8,6, @@BGX,@@BGY, bg_data)
    interactmap = TopoMap.new(8,6, @@BGX,@@BGY, interaction_data)
 
    bgsurface = JsonSurface.new([@@BGX,@@BGY])

    topomap.blit_to(pallette, bgsurface)
    npcs = []
    @npcs_hooks # ....TODO
    @worldstate2 = WorldState.new(topomap, pallette, terrainmap, terrain_pallette, interactmap, interaction_pallette, npcs, bgsurface)
  end

  # The "main loop". Repeat the #step method
  # over and over and over until the user quits.
  def go
    catch(:quit) do
      loop do
        step
      end
    end
  end

  def non_menu_hooks
    (@npc_hooks + @player_hooks + @menu_killed_hooks).flatten
  end

  def menu_hooks
    @menu_active_hooks
  end

  def battle_hooks
    @battle_active_hooks
  end
  def non_battle_hooks
    non_menu_hooks
  end
  def battle_begun(universe, player)
    toggle_battle_hooks(false)
  end
  def battle_completed
    toggle_battle_hooks(true)
  end

  


  def make_clock
    @clock = Clock.new()
    @clock.target_framerate = 50
    @clock.calibrate
    @clock.enable_tick_events
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

  def make_event_hooks
    always_on_hooks = {
      :escape => :quit,
      :q => :quit,
      QuitRequested => :quit,
      :c => :capture_ss,
      :d => :toggle_dialog_layer,
      :m => :toggle_menu
    }

    @always_on_hooks = make_magic_hooks( always_on_hooks )

    menu_killed_hooks = { :i => :interact_with_facing }
    @menu_killed_hooks = make_magic_hooks( menu_killed_hooks )
    puts @menu_killed_hooks.size
    menu_active_hooks = { :left => :menu_left, :right => :menu_right, :up => :menu_up, :down => :menu_down, :i => :menu_enter, :b => :menu_cancel }

    @menu_active_hooks = make_magic_hooks(menu_active_hooks)
    @menu_active_hooks.each do |hook|
      remove_hook(hook)
    end

    battle_hooks = {
      :left => :battle_left, :right => :battle_right, :up => :battle_up, :down => :battle_down,
      :i => :battle_confirm, :b => :battle_cancel
    }
    @battle_active_hooks = make_magic_hooks(battle_hooks)
    @battle_active_hooks.each do |hook|
      remove_hook(hook)
    end
    @battle_layer_hooks = make_magic_hooks_for(@battle_layer, { YesTrigger.new() => :handle } )
    @npcs.each {|npc|
      @npc_hooks << make_magic_hooks_for( npc, { YesTrigger.new() => :handle } )
    }
    @player_hooks = make_magic_hooks_for( @player, { YesTrigger.new() => :handle } )
    puts "player hooks: #{@player_hooks[0]}"

  end

  def toggle_battle_hooks(in_battle=false)
    EventManager.new.swap_event_sets(self, in_battle, non_battle_hooks, battle_hooks)
  end

  def toggle_menu
    EventManager.new.swap_event_sets(self, @menu_layer.active?, non_menu_hooks, @menu_active_hooks)
    @menu_layer.toggle_activity
  end
private
  def menu_enter(event)
    @menu_layer.enter_current_cursor_location(self)
  end

  def menu_cancel
    @menu_layer.cancel_action
  end

  def menu_up
    @menu_layer.move_cursor_up
  end
  def menu_down
    @menu_layer.move_cursor_down
  end
  def menu_left
    @menu_layer.cancel_action
  end
  def menu_right(event)
    @menu_layer.enter_current_cursor_location(self)
  end

  
  def battle_up
    @battle_layer.enter_current_cursor_location(self)
  end
  def battle_down
    @battle_layer.cancel_action
  end
  def battle_left
    @battle_layer.move_cursor_up
  end
  def battle_right
    @battle_layer.move_cursor_down
  end
  def battle_confirm
    @battle_layer.enter_current_cursor_location(self)
  end

  def battle_cancel
    @battle_layer.cancel_action
  end

  def toggle_dialog_layer
    @dialog_layer.toggle_visibility
  end
  def interact_with_facing(event)
    @player.interact_with_facing(self)
  end

  def capture_ss(event)
    #TODO this does not work, find a different way to dump screen data
#    def @screen.monkeypatch
#      filename = "screenshot.bmp"
#      result = SDL.SaveBMP_RW( @struct, filename )
#      if(result != 0)
#       raise( Rubygame::SDLError, "Couldn't save surface to file %s: %s"%\
#             [filename, SDL.GetError()] )
#      end
#      nil
#    end
    
    #@screen.savebmp("screenshot.bmp")

    SDL.SaveBMP_RW("screenshot.bmp",@screen, 0)
  end


  # Create an EventQueue to take events from the keyboard, etc.
  # The events are taken from the queue and passed to objects
  # as part of the main loop.
  def make_queue
    # Create EventQueue with new-style events (added in Rubygame 2.4)
    @queue = EventQueue.new()
    @queue.enable_new_style_events

    # Don't care about mouse movement, so let's ignore it.
    @queue.ignore = [MouseMoved]
  end


  # Create the Rubygame window.
  def make_screen
    #@screen = Screen.open( [640, 480] )
    @screen = Screen.new([@@SCREEN_X, @@SCREEN_Y])
    @screen.title = "Square! In! Space!"
  end

  def make_dialog_layer
    @dialog_layer = DialogLayer.new(@screen)
  end
  def make_universe
    @universe = Universe.new(0, [@worldstate, @worldstate2], @dialog_layer, @menu_layer, @battle_layer)
  end
  # Create the player ship in the middle of the screen
  def make_player
    #@player = Ship.new( @screen.w/2, @screen.h/2, @topomap, pallette, @terrainmap, terrain_pallette, @interactmap, interaction_pallette, @bgsurface )
    @hero = Hero.new("hero",  @@HERO_START_BATTLE_PTS, @@HERO_BATTLE_PTS_RATE)
    @hero2 = Hero.new("cohort", @@HERO_START_BATTLE_PTS, @@HERO_BATTLE_PTS_RATE)
    @party_inventory = Inventory.new(255) #TODO revisit inventory -- should it have a maximum? probably should not be stored on hero as well...
    @party = Party.new([@hero, @hero2], @party_inventory)
    @hero_x_dim = 48
    @hero_y_dim = 64
    @player_file = "Charactern8.png"
    @ssx = @screen.w/2
    @ssy = @screen.h/2
    @player = Player.new(@ssx, @ssy , @universe, @party, @player_file, @hero_x_dim, @hero_y_dim , @ssx, @ssy )

    # Make event hook to pass all events to @player#handle().
  end


  # Quit the game
  def quit
    puts "Quitting!"
    throw :quit
  end


  # Do everything needed for one frame.
  def step
    # Clear the screen.
    @screen.fill( :black )
#    puts "ship is at #{@player.px}, #{@player.py}"
#    puts "ship rect is #{@player.rect}"
#    puts "bg is #{@bgimage.size}"
    
    
    @sx = 640
    @sy = 480
    @universe.current_world.background_surface.blit(@screen, [0,0], [ @player.px - (@sx/2), @player.py - (@sy/2), @sx, @sy])

    @universe.current_world.npcs.each {|npc|

      npc.draw(@screen, @player.px, @player.py, @sx, @sy) if npc.nearby?(@player.px, @player.py, @sx/2, @sy/2)

    }
    
    #@topomap.blit_with_pallette(pallette, @screen, @player.px, @player.py)
#    puts "topomap should be in (#{@topomap.x_offset_for_world(@player.px)},#{@topomap.y_offset_for_world(@player.py)})"


    # Fetch input events, etc. from SDL, and add them to the queue.
    @queue.fetch_sdl_events

    # Tick the clock and add the TickEvent to the queue.
    tick = @clock.tick
    @queue << tick
    @hud.update :time => "Framerate: #{1.0/tick.seconds}"
    # Process all the events on the queue.
    @queue.each do |event|
      handle( event )
    end

    # Draw the ship in its new position.

    @player.draw(@screen)
    @hud.draw
    if @universe.dialog_layer.active?
      @universe.dialog_layer.draw
    end
    if @universe.menu_layer.active?
      @universe.menu_layer.draw
    end
    if @universe.battle_layer.active?
      @universe.battle_layer.draw
    end
    # Refresh the screen.
    @screen.update()
  end

  def tile(color)
    s = Surface.new([160,160])
    s.fill(color)
    s
  end
  def interaction_pallette
    pal = Hash.new(false)
    pal['O'] = OpenTreasure.new("O")
    pal['T'] = Treasure.new("T")
    pal['1'] = Treasure.new("1")
    pal['2'] = Treasure.new("2")
    pal['3'] = Treasure.new("3")

    pal['w'] = WarpPoint.new(1)
    pal['W'] = WarpPoint.new(0)

    pal
  end

  def terrain_pallette
    pal = Hash.new(true)
    pal['T'] = false
    pal['.'] = false
    pal['e'] = true
    pal
  end
  

  def pallette
    pal = Hash.new(tile(:blue))
    
    pal['O'] = JsonLoadableSurface.new("open-treasure-on-grass-bg-160.png")
    pal['T'] = JsonLoadableSurface.new("treasure-on-grass-bg-160.png")
    pal['w'] = JsonLoadableSurface.new("water-bg-160.png")
    pal['W'] = JsonLoadableSurface.new("town-on-grass-bg-160.png")
    pal['M'] = JsonLoadableSurface.new("mountain-bg-160.png")
    pal['G'] = JsonLoadableSurface.new("grass-bg-160.png")
    pal
  end



end


# Start the main game loop. It will repeat forever
# until the user quits the game!
Game.new.go


# Make sure everything is cleaned up properly.
Rubygame.quit()