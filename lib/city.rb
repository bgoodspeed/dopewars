# To change this template, choose Tools | Templates
# and open the template in the editor.

class City
  attr_reader :name, :price_factor, :core_drugs
  def initialize(name, price_factor, core_drugs = [])
    @name = name
    @price_factor = price_factor
    @core_drugs = core_drugs
  end

  def price_for(drug)
    drug.base_price * @price_factor
  end
end
