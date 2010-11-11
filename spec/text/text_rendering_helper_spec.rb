
require 'spec/rspec_helper'

describe TextRenderingHelper do
  include DomainMocks
  def mock_surface
    m = mock("surface")
    m
  end
  
  def mock_font
    m = mock("font")
    m
  end

  def expect_text_rendered(font, txt, surface)
    font.should_receive(:render).with(txt, anything, anything).and_return surface
  end
  def expect_surface_blitted(surface, count)
    surface.should_receive(:blit).at_least(count)
  end

  before(:each) do
    @txt_surface = mock_surface
    @layer = mock_layer
    @font = mock_font
    @conf = TextRenderingConfig.new(99, 88, 77, 66)
    @text_rendering_helper = TextRenderingHelper.new(@layer, @font)
  end



  it "should able to render lines onto a given surface" do
    expect_text_rendered(@font, "foo", @txt_surface)
    expect_text_rendered(@font, "bar", @txt_surface)
    expect_surface_blitted(@txt_surface, 2)
    @text_rendering_helper.render_lines_to(@layer, ["foo", "bar"], @conf, 0)
  end
end
