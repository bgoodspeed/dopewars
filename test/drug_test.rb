# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'drug'

class DrugTest < Test::Unit::TestCase
  def test_has_name_base_price_and_rarity
    @drug = Drug.new("Acid", 400)

    assert_equal("Acid", @drug.name)
    assert_equal(400, @drug.base_price)
    assert_equal(:common, @drug.rarity)
  end

  def test_rare_drugs_are_rare
    @drug = RareDrug.new("Fighter Pilot Shit", 3400)

    assert_equal(:rare, @drug.rarity)
    assert(@drug.rare?, "Failure message.")
  end

end
