
require 'spec/rspec_helper'

describe GameLayers do
  include DomainMocks
  include MethodDefinitionMatchers
  def mock_layer
    m = mock("layer")
    m
  end

  before(:each) do
    @game_layers = GameLayers.new(mock_layer,mock_layer,mock_layer,mock_layer)
  end

  it "should define layer accessors" do
    @game_layers.should define(:menu_layer)
  end
end
