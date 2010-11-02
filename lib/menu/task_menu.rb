# To change this template, choose Tools | Templates
# and open the template in the editor.

class TaskMenu
  def initialize(game, actions)
    @actions = actions
  end

  def elements
    @actions
  end
  def element_at(idx, selections)
    elements[idx]
  end
  def size(selections=nil)
    @actions.size
  end

  def satisfiable_and_selected(selections)
    @actions.select {|action| action.selected_and_satisfied_by?(selections)}
  end

  def any_satisfiable_and_selected?(selections)
    !satisfiable_and_selected(selections).empty?
  end

  def size_at(path, selections)
    navigate_path(path).size(selections)
  end

  def element_names(selections)
    elements.collect {|el| el.name }
  end

  def navigate_path(path)
    return self if path.empty?
    cp = path.clone
    @actions[cp.shift].navigate_path(cp)
  end

  def navigate_path_to_select(path,  selections)
    raise "this better not fucking happen" if path.empty?
    return @actions[path.first] if path.size == 1
    cp = path.clone
    @actions[cp.shift].navigate_path_to_select(cp, selections)
    
  end
  def path_element_at(path, current_position, selections)
    navigate_path(path).element_at(current_position, selections)
  end

  def element_names_at(path, selections)
    navigate_path(path).element_names(selections)
  end
  def element_name_at(path, current_position, selections)
    path_element_at(path, current_position, selections).name
  end

  def draw(menu_layer_config, path, selections)
    @actions.each_with_index {|action, index| 
      action.draw(menu_layer_config, path, index, selections)
    }
  end
end
