
require 'spec/rspec_helper'

describe OpenTreasure do
  before(:each) do
    @open_treasure = OpenTreasure.new("treasure")
  end

  it "should be a noop for activation" do
    @open_treasure.activate(nil, nil, nil, nil, nil)
  end
end
