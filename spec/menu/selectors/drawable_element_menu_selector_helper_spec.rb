
require 'spec/rspec_helper'

class FakeDrawable
  include DrawableElementMenuSelectorHelper
  
  def initialize(elems)
    @elements = elems
  end

  def elements(selections=nil)
    @elements
  end
end

describe DrawableElementMenuSelectorHelper do
  include DomainMocks
  include MethodDefinitionMatchers
  
  before(:each) do
    @text_helper = mock("text helper")
    @helper = FakeDrawable.new([named_mock("foo"), named_mock("bar")])
  end

  it "should give draw methods" do
    @helper.should define(:draw)
  end

  it "draw by rendering" do
    expect_render_lines_to_layer(@text_helper)
    @helper.draw(:conf, @text_helper, nil)
  end
  
end
