
require 'spec/rspec_helper'

describe CharacterAttribution do
  include DomainMocks

  def mock_state
    m = mock("state")
    m
  end
  def mock_equipment
    m = mock("equipment")
    m
  end
  
  before(:each) do
    @state = mock_state
    @equipment = mock_equipment
    @item = mock_item
    @character_attribution = CharacterAttribution.new(@state, @equipment)
  end

  it "should define stat ordering" do
    @character_attribution.stats_ordering.should == [:hp, :mp, :exp, :lvp]
  end

  it "should consume items" do
    effects = stub_effects(@item)
    expect_add_effects(@state)
    expect_consumed(@item)
    @character_attribution.consume_item(@item)
  end
  it "should consume level up" do
    expect_add_attributes(@state)
    expect_subtract_level_points(@state)
    @character_attribution.consume_level_up(0)
  end

  it "is json ified" do
    @character_attribution.json_params.should be_an_instance_of(Array)
  end
end
