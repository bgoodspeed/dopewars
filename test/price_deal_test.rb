# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'price_deal'

class PriceDealTest < Test::Unit::TestCase
  def test_price_deal_takes_drug_name_price_fluctuation_and_msg
    @price_deal = PriceDeal.new(:acid, 0.1, "Some Msg")

    assert_equal(@price_deal.price_factor, 0.1)
    assert_equal(@price_deal.explanation, "Some Msg")
  end

  def test_price_deal_looks_up_drug_by_name_to_determine_price
    @price_deal = PriceDeal.new(:acid, 0.5, "Half Price Acid")
    acid = AllDrugs.for_name(:acid)
    assert_equal(acid.base_price, 800)
    assert_equal(@price_deal.price_of(acid), 400)

  end

  def test_can_check_for_applicability
    @price_deal = PriceDeal.new(:acid, 0.5, "Half Price Acid")
    acid = AllDrugs.for_name(:acid)
    acid2 = AllDrugs.for_name(:acid)
    weed = AllDrugs.for_name(:weed)

    assert_not_equal( acid, weed)
    assert_equal(acid, acid2)

    assert(@price_deal.applies_to?(acid))
    assert(@price_deal.applies_to?(acid2))
    assert(!@price_deal.applies_to?(weed))
  end
end
