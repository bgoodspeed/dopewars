# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'world'
require 'city'
require 'hero'

class WorldTest < Test::Unit::TestCase

  def setup
    @hero = Hero.new
    @city_a = City.new("A", 1)
    @world = World.new(@hero, [@city_a, City.new("B", 2), City.new("C", 0.5)])
  end

  def test_gets_created_with_hero_and_list_of_cities
    assert_equal(@world.cities.size, 3)
    assert_equal(@world.hero, @hero)
    assert_equal(@world.day, 0)
    assert_nil(@world.hero_location)
  end

  def test_traveling_takes_up_one_day
    assert_equal(@world.day, 0)
    assert_nil(@world.hero_location)
    @world.travel(@city_a)
    assert_equal(@world.day, 1)
    assert_equal(@city_a, @world.hero_location)
  end

  def test_travelling_takes_up_one_day_unless_it_matches_current_location
    @world.travel(@city_a)
    assert_equal(@world.day, 1)
    @world.travel(@city_a)
    assert_equal(@world.day, 1)
    assert_equal(@city_a, @world.hero_location)
    
  end

  def test_visit_marketplace_uses_current_location
    @world.travel(@city_a)
    market = @world.visit_marketplace

    assert_instance_of(Marketplace, market)
    assert_equal(@city_a, market.city)
  end

  
end
