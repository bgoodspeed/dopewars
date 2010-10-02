# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'viewport'


class ViewportTest < Test::Unit::TestCase
  def test_builds_viewport
    @viewport = Viewport.new(160,160, 4,3, ['A','B','C','D','E','F','G','H','I','J','K','L'])
    
  end
end
