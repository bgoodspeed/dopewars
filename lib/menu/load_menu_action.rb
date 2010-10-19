
class LoadMenuAction < SaveLoadMenuAction
  def activate(menu_idx, game, submenu_idx)
    slot = save_slot(submenu_idx)
    puts "load from #{slot}"

    data = IO.readlines(slot)

    rebuilt = JSON.parse(data.join(" "))
    puts "got rebuilt: #{rebuilt.class} "
    ReloaderHelper.new.replace(game, rebuilt)
    game.add_notification(WorldScreenNotification.new("Loaded from #{slot}"))
  end
end
