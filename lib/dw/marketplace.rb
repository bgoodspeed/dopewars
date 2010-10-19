# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'all_drugs'

class Marketplace
  attr_reader :drugs, :city
  def initialize(city, min_drugs, deals = [])
    @city = city
    @min_drugs = min_drugs
    @deals = deals
    @drugs = AllDrugs.with(city.core_drugs, min_drugs)
  end

  def price_of(drug)
    relevent_deals = @deals.select { |deal| deal.applies_to?(drug) }

    factor = 1
    unless relevent_deals.empty?
      factor = relevent_deals[0].price_factor
    end



    @city.price_for(drug) * factor
  end

  def buy(hero, drug, quantity)
    total_price = price_of(drug) * quantity

    return false if hero.money < total_price
    hero.spend(total_price)
    hero.acquire_drug(drug, quantity)
  end

  def sell(hero, drug, quantity)
    return false if hero.quantity_of(drug) < quantity

    total_value = price_of(drug) * quantity

    hero.remove_drug(drug, quantity)
    hero.earn(total_value)
    
  end
end
