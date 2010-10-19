
class WorldWeaponHelper

  extend Forwardable
  def_delegators :@weapon, :draw_weapon
  def_delegators :@interaction_helper, :facing, :facing=

  def initialize(player, universe)
    @player = player
    @weapon = nil
    @universe = universe
    @interaction_helper = WorldWeaponInteractionHelper.new(@player, @universe, InteractionPolicy.process_all)
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
    else
      @interaction_helper.interact_with_facing(@universe.game, @player.px, @player.py)
    end
  end


end
