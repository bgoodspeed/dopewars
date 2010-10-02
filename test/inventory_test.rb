# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'inventory'
require 'all_drugs'
class InventoryTest < Test::Unit::TestCase
  def setup
    @inventory = Inventory.new(20)
  end


  def test_quantity_of_is_zero_for_missing_drugs
    assert_equal(0, @inventory.quantity_of(AllDrugs.for_name(:weed)))
  end

  def test_add_item_uses_new_slot_for_new_item
    assert_equal(20, @inventory.free_slots)
    @inventory.add_item(2, AllDrugs.for_name(:acid))
    assert_equal(19, @inventory.free_slots)
  end


  def test_add_item_uses_existing_slot_for_extra_items
    assert_equal(20, @inventory.free_slots)
    @inventory.add_item(2, AllDrugs.for_name(:acid))
    assert_equal(19, @inventory.free_slots)
    @inventory.add_item(3, AllDrugs.for_name(:acid))
    assert_equal(19, @inventory.free_slots)
  end


  def test_quantity_of_is_known_for_new_item
    @inventory.add_item(2, AllDrugs.for_name(:acid))
    assert_equal(2, @inventory.quantity_of(AllDrugs.for_name(:acid)))
  end

  def test_quantity_of_is_updated_for_existing_items
    @inventory.add_item(2, AllDrugs.for_name(:acid))
    @inventory.add_item(5, AllDrugs.for_name(:acid))
    assert_equal(7, @inventory.quantity_of(AllDrugs.for_name(:acid)))
  end

  def test_free_slots_are_used_for_different_drugs
    assert_equal(20, @inventory.free_slots)
    @inventory.add_item(2, AllDrugs.for_name(:acid))
    assert_equal(19, @inventory.free_slots)
    @inventory.add_item(3, AllDrugs.for_name(:acid))
    assert_equal(19, @inventory.free_slots)
    @inventory.add_item(1, AllDrugs.for_name(:weed))
    assert_equal(18, @inventory.free_slots)
  end

  def test_remove_item_throws_exception_for_missing_item
    begin
      @inventory.remove_item(1, AllDrugs.for_name(:weed))
      flunk "should not allow removal of items we dont have"
    rescue InsufficientItemsToRemoveException => ex
      #noop
    end
  end

  def test_remove_item_throws_exception_for_too_many_items
    begin
      @inventory.add_item(1, AllDrugs.for_name(:weed))
      @inventory.remove_item(2, AllDrugs.for_name(:weed))
      flunk "should not allow removal of more items than we have"
    rescue InsufficientItemsToRemoveException => ex
      #noop
    end

  end

  def test_remove_item_removes_item_by_quantity
    @inventory.add_item(1, AllDrugs.for_name(:weed))
    @inventory.remove_item(1, AllDrugs.for_name(:weed))
    assert_equal(0, @inventory.quantity_of(AllDrugs.for_name(:weed)))
  end

end
