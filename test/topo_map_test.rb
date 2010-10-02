# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'topo_map'

class TopoMapTest < Test::Unit::TestCase

  def setup
    @topo = TopoMap.new(2,3, 200, 300, ['a', 'b','c','d','e','f'])
  end

  def test_data_at
    assert_equal('a', @topo.data_at(0,0))
    assert_equal('b', @topo.data_at(1,0))
    assert_equal('d', @topo.data_at(1,1))
    assert_equal('f', @topo.data_at(1,2))
    assert_equal('e', @topo.data_at(0,2))
  end

  def test_viewport_data
    assert_equal ['a'], @topo.viewport_data_for(0,0,1,1)
    assert_equal ['a', 'c'], @topo.viewport_data_for(0,0,1,2)
    assert_equal ['a', 'b'], @topo.viewport_data_for(0,0,2,1)
    assert_equal ['a', 'b', 'c', 'd'], @topo.viewport_data_for(0,0,2,2)
    assert_equal ['b'], @topo.viewport_data_for(1,0,1,1)
    assert_equal ['b', 'd'], @topo.viewport_data_for(1,0,1,2)
  end

  def test_can_calculate_offsets_from_world_coords
    assert_equal(0, @topo.x_offset_for_world(0))
    assert_equal(0, @topo.x_offset_for_world(99))
    assert_equal(1, @topo.x_offset_for_world(101))
    
    assert_equal(0, @topo.y_offset_for_world(0))
    assert_equal(0, @topo.y_offset_for_world(99))
    assert_equal(1, @topo.y_offset_for_world(101))
    assert_equal(1, @topo.y_offset_for_world(199))
    assert_equal(2, @topo.y_offset_for_world(201))
    
  end

  def test_can_calculate_boundaries_from_tile_coords
    assert_equal(0, @topo.left_side(0))
    assert_equal(100, @topo.left_side(1))
    assert_equal(100, @topo.right_side(0))
    assert_equal(200, @topo.right_side(1))
    assert_equal(0, @topo.top_side(0))
    assert_equal(100, @topo.top_side(1))
    assert_equal(100, @topo.bottom_side(0))
    assert_equal(200, @topo.bottom_side(1))


  end
end
