
class SaveMenuAction < SaveLoadMenuAction
  def activate(menu_idx, game, submenu_idx)
    puts "saving: #{game.player}"
    json = JSON.generate(game.player)
    slot = save_slot(submenu_idx)
    save_file = File.open(slot, "w")
    save_file.puts json
    save_file.close
    puts "saving to slot #{submenu_idx}, json data is: "
    puts "player was at #{game.player.px} and #{game.player.py} at save time"
    puts "save action believes the menu layer to be active? #{game.universe.menu_layer.active}"
    game.toggle_menu
    game.add_notification(WorldScreenNotification.new("Saved to #{slot}"))
  end
end
