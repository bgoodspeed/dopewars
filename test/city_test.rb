# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'city'
require 'drug'

class CityTest < Test::Unit::TestCase
  def test_city_has_name_and_price_factor
    @city = City.new("Halifax", 0.5)
    assert_equal("Halifax", @city.name)
    assert_equal(0.5, @city.price_factor)
  end

  def test_city_influences_prices
    @full_price = City.new("Full Price", 1)
    @half_price = City.new("Half Price", 0.5)
    @twice_price = City.new("Twice Price", 2)

    @one_dollar_drug = Drug.new("Dollar", 1)
    @one_hundred_dollar_drug = Drug.new("100 Dollars", 100)

    assert_equal(1, @full_price.price_for(@one_dollar_drug))
    assert_equal(100, @full_price.price_for(@one_hundred_dollar_drug))
    assert_equal(0.5, @half_price.price_for(@one_dollar_drug))
    assert_equal(50, @half_price.price_for(@one_hundred_dollar_drug))
    assert_equal(2, @twice_price.price_for(@one_dollar_drug))
    assert_equal(200, @twice_price.price_for(@one_hundred_dollar_drug))

  end

  def test_city_has_list_of_default_drugs
    @city = City.new("Place", 1, [:acid, :weed])
    assert_equal(2, @city.core_drugs.size)
  end
  
end
