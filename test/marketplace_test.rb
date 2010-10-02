# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'marketplace'
require 'city'
require 'price_deal'
require 'hero'
class MarketplaceTest < Test::Unit::TestCase

  def setup
    @hero = Hero.new
    @city = City.new("Wherever", 1, [:acid, :weed])
    @marketplace = Marketplace.new(@city, 5)
    @acid = AllDrugs.for_name(:acid)
  end

  def test_marketplace_has_city_and_list_of_drugs_available
    drugs = @marketplace.drugs
    assert_equal(5, drugs.size)
    
    assert_contains(drugs, @acid)
    assert_contains(drugs, AllDrugs.for_name(:weed))
  end

  def test_has_deal_mapping_to_further_influence_prices
    @city = City.new("Wherever", 1.2, [:acid, :weed])

    @marketplace = Marketplace.new(@city, 5, [ PriceDeal.new(:acid, 0.5, "sale")])
    
    assert_equal( 800 * 1.2, @city.price_for(@acid))
    assert_equal(1.2 * 800 * 0.5, @marketplace.price_of(@acid))
    
  end

  def test_can_buy_drugs_and_insert_into_hero
    @hero.earn(10000)
    assert @marketplace.buy(@hero, @acid, 10)
    assert_equal(10, @hero.quantity_of(@acid))
    assert_equal(2000, @hero.money)
  end

  def test_insufficient_funds_will_cause_buy_to_return_false
    assert !@marketplace.buy(@hero, @acid, 10)
  end

  def test_can_sell_drugs_and_earn_money
    @hero.acquire_drug(@acid, 10)
    assert_equal 0, @hero.money
    assert_equal(10, @hero.quantity_of(@acid))
    assert @marketplace.sell(@hero, @acid, 5)
    assert_equal(5, @hero.quantity_of(@acid))
    assert_equal 4000, @hero.money

  end

  def assert_contains(collection, element)
    assert(collection.include?(element), "Expected #{collection} to hold #{element}")
  end
end
