# To change this template, choose Tools | Templates
# and open the template in the editor.

class Drug
  attr_reader :name, :base_price, :rarity
  def initialize(name, price)
    @name = name
    @base_price = price
    @rarity = :common
  end

  def rare?
    @rarity == :rare
  end


end

class RareDrug < Drug
  def initialize(name, price)
    super(name,price)
    @rarity = :rare
  end
end