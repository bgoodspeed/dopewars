# To change this template, choose Tools | Templates
# and open the template in the editor.

module DrawableElementMenuSelectorHelper

  def element_names(selections)
    elements.collect {|el| el.name }
  end

  def size(selectios=nil)
    elements.size
  end

  def select_element_at(idx, selections)
    elements[idx]
  end

  alias_method :element_at, :select_element_at
  def draw(config, text_rendering_helper, currently_selected)
    member_names = elements.collect {|m| m.name}
    text_rendering_helper.render_lines_to_layer( member_names, config)
  end
    
end
