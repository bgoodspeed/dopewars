# To change this template, choose Tools | Templates
# and open the template in the editor.

class StaticMenuElementDataSource
  attr_reader :name
  def initialize(name, submenus)
    @name = name
    @submenus = submenus
  end

  def size
    @submenus
  end
end

class StaticMenuSelector
  def initialize(configs)
    @elements = []
    configs.each {|conf|
      conf[:submenus]
      GameMenu.new(StaticMenuElementDataSource.new(conf[:name], conf[:submenus]))
    }
  end


  def element_at(idx, selections)
    @elements[idx]
  end

  def size(selections=nil)
    @elements.size
  end
end
