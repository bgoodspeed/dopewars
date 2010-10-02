# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'position'

class PositionableTest < Test::Unit::TestCase
  def setup
    @position = Position.new(0,0)
  end

  def test_position_is_updated_via_accel
    @position.update_all(1, 0, 1)
    assert_equal @position.x, 400.0
    assert_equal @position.y, 0
  end
  def test_position_is_updated_via_accel_y
    @position.update_all(0, 1, 1)
    assert_equal @position.x, 0
    assert_equal @position.y, 400.0
  end
 def test_position_is_updated_via_accel_diag
    @position.update_all(1, 1, 1)
    assert_equal @position.x, 400.0
    assert_equal @position.y, 400.0
  end

 def test_position_after_slowed_accel
    @position.update_all(1, 0, 1)
    @position.update_all(-1, 0, 0.5)
    assert_equal @position.x, 300.0
    assert_equal @position.y, 0
 end
end
