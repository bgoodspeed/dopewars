
require 'spec/rspec_helper'

describe AbstractLayer do
  include DomainMocks

  before(:each) do
    @screen = mock_screen
    @layer = AbstractLayer.new(@screen, 999, 888)
  end

  it "should be inactive by default" do
    @layer.active.should be_false
  end
end
