
class EventManager
  def swap_event_sets(game, already_active, toggled_hooks, menu_active_hooks)
    if already_active
      menu_active_hooks.each {|hook|
        game.remove_hook(hook)
      }
      toggled_hooks.each {|hook|
        game.append_hook(hook)
      }
    else
      toggled_hooks.each {|hook|
        game.remove_hook(hook)
      }
      menu_active_hooks.each {|hook|
        game.append_hook(hook)
      }
    end

  end
end
