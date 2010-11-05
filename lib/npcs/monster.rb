
class Monster
  include ScreenOffsetHelper
  include Rubygame
  include Rubygame::Events
  include Sprites::Sprite
  

  include EventHandler::HasEventHandler
  
  
  extend Forwardable
  def_delegators :@coordinate_helper, :px, :py, :collides_on_x?, :collides_on_y?

  def_delegators :@character_attribution, :take_damage, :experience, :dead?, :damage, :consume_item, :current_hp
  def_delegators :@readiness_helper, :consume_readiness
  def_delegator :@readiness_helper, :points, :readiness_points


  attr_reader :inventory, :player
  def initialize(player, universe, filename, position, inventory=Inventory.new(255), character_attrib=nil, ai=nil)
    @npc_x = position.dimension.x
    @npc_y = position.dimension.y
    @filename = filename
    @universe = universe
    @player = player
    @ai = ai
    @animated_sprite_helper = AnimatedSpriteHelper.new(filename, position)
    @keys = AlwaysDownMonsterKeyHolder.new
    
    @coordinate_helper = MonsterCoordinateHelper.new(position, @keys, @universe ,100, 300,200)
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
    game.battle_begun(universe,player) #TODO these calls are weirdly coupled ... fix it with a better battle menu test
    game.start_battle(self)
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
