
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
    @character_attribution = CharacterAttribution.new(@state, @equipment)
  end

  it "should define stat ordering" do
    @character_attribution.stats_ordering.should == [:hp, :mp, :exp, :lvp]
  end
end
