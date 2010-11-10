
require 'spec/rspec_helper'

class FakeColorKeyHolder
  include ColorKeyHelper
end

describe ColorKeyHelper do
  include DomainMocks
  include MethodDefinitionMatchers

  before(:each) do
    @holder = FakeColorKeyHolder.new
  end

  it "should define set_color_key_from_corner" do
    @holder.should define(:set_colorkey_from_corner)
  end
  
  it "should ask the surface for its color in the top left corner" do
    surf = mock("surface")
    surf.should_receive(:get_at).with(0,0).and_return 3
    surf.should_receive(:colorkey=).with(3)
    
    @holder.set_colorkey_from_corner(surf)
  end
end
