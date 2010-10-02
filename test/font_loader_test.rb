# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'font_loader'

class FontLoaderTest < Test::Unit::TestCase
  include FontLoader

  def test_knows_default_font_path
    assert font_path.end_with?("fonts")
  end

  def test_throws_an_exception_for_missing_fonts
    begin
      load_font("gibberish")
      flunk "should have blown up"
    rescue MissingResourceError => e
      assert_equal e.class, MissingResourceError
    end
  end

  def test_returns_ttf_object_for_valid_font
    load_font("FreeSans.ttf")
  end

  def test_can_be_used_as_module
    
  end
end
