# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'hero'
require 'all_drugs'

class HeroTest < Test::Unit::TestCase

  def setup
        @hero = Hero.new
  end
  def test_has_money_and_inventory


    assert_equal 20, @hero.free_inventory_slots
    assert_equal 0, @hero.money

    
  end

  def test_can_earn_and_spend
    assert_equal(0, @hero.money)
    @hero.earn(30)
    assert_equal(30, @hero.money)
    @hero.spend(10)
    assert_equal(20, @hero.money)
    @hero.spend(20)
    assert_equal(0, @hero.money)
  end

  def test_cant_spend_more_than_earned
    @hero.earn(20)
    begin
      @hero.spend(21)
      flunk "should not allow spending more than hero has earned"
    rescue InsufficientMoneyException => ex
      # noop
    end

  end

  def test_can_query_for_quantity_of_drugs
    @acid = AllDrugs.for_name(:acid)
    assert_equal(0, @hero.quantity_of(@acid))
    @hero.acquire_drug(@acid, 10)
    assert_equal(10, @hero.quantity_of(@acid))
    @hero.remove_drug(@acid, 5)
    assert_equal(5, @hero.quantity_of(@acid))
  end
end
