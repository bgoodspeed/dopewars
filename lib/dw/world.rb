# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'marketplace'

class World
  @@MIN_DRUGS_PER_CITY = 6
  attr_reader :hero, :cities, :day, :hero_location
  def initialize(hero, cities)
    @cities = cities
    @hero = hero
    @day = 0
    @hero_location = nil
  end

  def travel(location)
    
    @day += 1 unless @hero_location == location
    @hero_location = location
  end

  def visit_marketplace
    Marketplace.new(@hero_location, @@MIN_DRUGS_PER_CITY)
  end
end
