#TODO rename to process
class BattleVictoryHelper

  def end_battle_from(battle)
    give_spoils(battle.player, battle.monster)
    monster_killed(battle.universe,battle.monster)

  end

  def monster_killed(universe, monster)
    universe.current_world.delete_monster(monster)
  end
  def give_spoils(player,monster)
    player.gain_experience(monster.experience)
    player.gain_inventory(monster.inventory)

  end
end
