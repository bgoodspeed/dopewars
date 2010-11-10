
require 'spec/rspec_helper'

describe Hud do
  include MethodDefinitionMatchers
  before(:each) do
    @hud = Hud.new({})
  end

  it "should define draw" do
    @hud.should define(:draw)
  end
  it "should define update" do
    @hud.should define(:update)
  end
end
