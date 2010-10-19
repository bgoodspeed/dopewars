
class WorldWeaponInteractionHelper < InteractionHelper
  def interact_with_current_tile(game, tilex, tiley)
    puts "noop current"
  end

  def interact_with_dialog
    puts "noop dialog"
  end

  def interact_with_facing_tile(game, facing_tilex, facing_tiley, facing_tile)
    puts "noop facing"
  end

  def interact_with_npc(game, interactable_npcs)
    puts "noop npc"
  end
end

