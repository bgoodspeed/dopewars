# To change this template, choose Tools | Templates
# and open the template in the editor.

class MonsterFactory
  def make_monster(player,universe)
    monster_inv = Inventory.new(255)
    monster_inv.add_item(1, GameItemFactory.potion)
    monattrib = CharacterAttribution.new(
      CharacterState.new(CharacterAttributes.new(3, 0, 1, 0, 0, 0, 0, 0)),
      EquipmentHolder.new)
    monai = ArtificialIntelligence.new(RepeatingPathFollower.new("DRUL", 80), BattleStrategy.new([BattleTactic.new("Enemy: Any -> Attack")]))
    Monster.new(player,universe,"monster.png", 400,660, @@MONSTER_X, @@MONSTER_Y, monster_inv, monattrib, monai)
  end
end
