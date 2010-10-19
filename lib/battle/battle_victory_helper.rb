#TODO rename to process
class BattleVictoryHelper

  def monster_killed(universe, monster)
    universe.current_world.delete_monster(monster)
  end
  def give_spoils(player,monster)
    player.gain_experience(monster.experience)
    player.gain_inventory(monster.inventory)

  end
end
