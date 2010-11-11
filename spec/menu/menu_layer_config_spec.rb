
require 'spec/rspec_helper'

describe MenuLayerConfig do
  include MethodDefinitionMatchers

  before(:each) do
    @menu_layer_config = MenuLayerConfig.new
  end

  it "should define config sections" do
    @menu_layer_config.should define(:main_menu_text)
  end
end
