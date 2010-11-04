
class Battle
  extend Forwardable
  def_delegators :@player, :party, :dead?, :inventory_item_at

  attr_reader :monster, :player, :universe, :game
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

  def first_monster
    monsters.first
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


  def hero_by_name(name)
    found = heroes.select{ |h| h.name == name}
    found.empty? ? nil : found.first
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
    helper.end_battle_from(self)
  end
end
