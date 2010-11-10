
require 'spec/rspec_helper'

describe CharacterAttributionFactory do
  before(:each) do
    @character_attribution_factory = CharacterAttributionFactory.new
  end

  def make_attribs
    @character_attribution_factory.make_attributes
  end

  it "should make attributes" do
    make_attribs.should be_an_instance_of(CharacterAttributes)
  end
  it "should make attribution" do
    @character_attribution_factory.make_attribution(make_attribs).should be_an_instance_of(CharacterAttribution)
  end
end
