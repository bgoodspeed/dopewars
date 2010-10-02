# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'all_drugs'

class PriceDeal
  attr_reader :price_factor, :explanation
  def initialize(name, price_factor, explanation)
    @name = name
    @price_factor = price_factor
    @explanation = explanation
    
  end

  def applies_to?(drug)
    AllDrugs.for_name(@name) == drug
  end

  def price_of(drug)
    drug.base_price * @price_factor
  end
end
