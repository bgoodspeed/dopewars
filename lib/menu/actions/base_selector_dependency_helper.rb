# To change this template, choose Tools | Templates
# and open the template in the editor.

module BaseSelectorDependencyHelper
  
   attr_reader :dependencies, :name, :game

   def element_at(idx, selections)
     dependencies[idx]
   end

   def satisfied_by?(selections)
     dependencies.each { |the_dependency|
       return false unless selections.satisfy?(the_dependency)
     }
     true
   end

   def navigate_path(path)
     dependencies[path.size]
   end

   def navigate_path_to_select(path, selections)
     dependencies[path.size - 1].element_at(path[path.size - 1], selections)
   end

   def selection_match?(selections)
     selections.has_selected?(self.class)
   end

   def selected_and_satisfied_by?(selections)
     selection_match?(selections) && satisfied_by?(selections)
   end

   def path_or_dep_size(path)
     [path.size, dependencies.size].min
   end
   def draw_deps(menu_layer_config, path, index, selections)
     trh = text_rendering_helper_from(game)
     path_or_dep_size(path).times {|dependency_index|
       dependencies[dependency_index].draw(
          menu_layer_config.selector_menu_text_config_at_depth(dependency_index),
          trh, selections)
      }
   end

   def draw(menu_layer_config, path, index, selections)
     trh = text_rendering_helper_from(game)
     trh.render_lines_to_layer( [name], menu_layer_config.main_menu_text.offset_by(index))

     if selection_match?(selections)
       draw_deps(menu_layer_config, path, index, selections)
     end
   end
    
end
