# To change this template, choose Tools | Templates
# and open the template in the editor.

class MonsterFactory
  def make_monster(player,universe)
    monster_inv = Inventory.new(255)
    monster_inv.add_item(1, GameItemFactory.potion)
    monattrib = CharacterAttributionFactory.new.make_attribution(CharacterAttributes.new(3, 0, 1, 0, 0, 0, 0, 0))
    monai = ArtificialIntelligence.new(RepeatingPathFollower.new("DRUL", 80), BattleStrategy.new([BattleTactic.new("Enemy: Any -> Attack")]))

    posn = PositionedTileCoordinate.new(SdlCoordinate.new(400, 660), SdlCoordinate.new(@@MONSTER_X, @@MONSTER_Y))
    Monster.new(player,universe,"monster.png", posn, monster_inv, monattrib, monai)
  end
end
