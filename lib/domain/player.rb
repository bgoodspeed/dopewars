
class Player
  include Rubygame
  include Rubygame::Events
  include Sprites::Sprite
  include EventHandler::HasEventHandler

  attr_accessor :universe, :party

  extend Forwardable

  def_delegators :@interaction_helper, :facing
  def_delegators :@animated_sprite_helper, :image, :rect
  def_delegators :@coordinate_helper, :update_tile_coords, :px, :py, :get_position
  def_delegators :@weapon_helper, :use_weapon, :using_weapon?, :draw_weapon
  def_delegators :@party, :add_readiness, :gain_experience, :gain_inventory,
    :inventory, :dead?, :inventory_info, :inventory_item_at, :world_weapon,
    :inventory_count
  def_delegators :@keys, :clear_keys
  def_delegators :@mission_archive, :mission_achieved?

  def_delegator :@mission_archive, :missions, :player_missions

  def_delegator :@party, :add_item, :add_inventory
  def_delegator :@party, :members, :party_members


  attr_reader :filename, :hero_x_dim, :hero_y_dim
  def initialize( position,  universe, party, filename, sx, sy, game)
    @game = game
    @universe = universe
    @filename = filename
    @hero_x_dim = position.dimension.x
    @hero_y_dim = position.dimension.y
    
    @interaction_helper = InteractionHelper.new(game, InteractionPolicy.immediate_return)
    @keys = KeyHolder.new
    @coordinate_helper = CoordinateHelper.new(position, @keys, @universe)
    @animation_helper = AnimationHelper.new(@keys)
    @weapon_helper = WorldWeaponHelper.new(game)
    sprite_pos = position.clone
    sprite_pos.position = SdlCoordinate.new(sx,sy)
    @animated_sprite_helper = AnimatedSpriteHelper.new(filename, sprite_pos)
    @mission_archive = MissionArchive.new(game)
    @party = party

    make_magic_hooks(
      KeyPressed => :key_pressed,
      KeyReleased => :key_released,
      ClockTicked => :update
    )
  end

  def set_key_pressed_for(key, ticks)
    update_facing_if_key_matches(key)
    update_animated_sprite_helper(key)
    @keys.set_timed_keypress(key, ticks)
  end

  def set_key_pressed_for_time(key, ms)
    update_facing_if_key_matches(key)
    update_animated_sprite_helper(key)
    @keys.set_timed_keypress_in_ms(key, ms)
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

  def update_facing_if_key_matches(newkey)
    if [:down, :left,:up, :right].include?(newkey)
      @interaction_helper.facing = newkey
      @weapon_helper.facing = newkey
    end

  end

  def update_animated_sprite_helper(newkey)
    @animated_sprite_helper.set_frame_from(newkey)
    @animated_sprite_helper.replace_avatar(@animation_helper.current_frame)

  end

  def key_pressed( event )
    newkey = event.key
    update_facing_if_key_matches(newkey)
    update_animated_sprite_helper(newkey)

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
    @keys.update_timed_keys(dt)
  end

  def x_ext
    @hero_x_dim/2
  end
  def y_ext
    @hero_y_dim/2
  end

end
