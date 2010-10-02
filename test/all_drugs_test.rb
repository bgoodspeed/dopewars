# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'all_drugs'

class AllDrugsTest < Test::Unit::TestCase
  def test_can_get_list_of_all_known_drugs
    assert_equal(AllDrugs.drugs.size, 15)
  end

  def test_can_get_all_rare_drugs
    drugs = AllDrugs.rare_drugs
    assert_equal(drugs.size, 2)
    drugs.each {|drug| assert_equal(:rare, drug.rarity)}
    
  end

  def test_can_get_all_common_drugs
    drugs = AllDrugs.common_drugs
    assert_equal(drugs.size, 13)
    drugs.each {|drug| assert_equal(:common, drug.rarity)}

  end

  def test_drug_for_symbol
    drug = AllDrugs.for_name(:acid)

    assert_equal("Acid", drug.name)
  end

  def test_can_obtain_n_drugs_given_k
    assert_equal(AllDrugs.with([:acid, :weed], 3).size, 3)
    assert_equal(AllDrugs.with([:acid, :weed], 2).size, 2)
    assert_equal(AllDrugs.with([:acid, :weed], 1).size, 2)
    
  end

end
