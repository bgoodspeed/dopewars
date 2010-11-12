
require 'spec/rspec_helper'

describe InterpretedMap do
  include DomainMocks

  def mock_topo_map
    m = mock("topo_map")
    m
  end
  def mock_pallette
    m = mock("pallette")
    m
  end


  before(:each) do
    @topo = mock_topo_map
    @pallette = mock_pallette
    @pallette2 = mock_pallette
    @interpreted_map = InterpretedMap.new(@topo, @pallette)
    @interpreted_map2 = InterpretedMap.new(@topo, @pallette2)
  end

  it "can interpret" do
    datum = expect_data_query(@topo, 0, 0)
    expect_pallette_conversion(@pallette, datum)
    @interpreted_map.interpret(0, 0)
  end

  it "can query for walkability" do
    datum = expect_data_query(@topo, 0, 0)
    expect_pallette_conversion(@pallette, datum, mock_blocking)
    @interpreted_map.can_walk_at?(0, 0).should be_false
  end
  it "can query for walkability non-blocking" do
    datum = expect_data_query(@topo, 0, 0)
    expect_pallette_conversion(@pallette, datum, mock_blocking(false))
    @interpreted_map.can_walk_at?(0, 0).should be_true
  end

  it "can replace the pallette" do
    @interpreted_map.pallette.should == @pallette
    @interpreted_map.replace_pallette(@interpreted_map2)
    @interpreted_map.pallette.should == @pallette2
  end

  it "can blit the foreground" do
    expect_blit_foreground(@interpreted_map.topo_map)
    @interpreted_map.blit_foreground(mock_screen, 0, 0)
  end

  it "is json ified" do
    @interpreted_map.json_params.should be_an_instance_of Array
  end
end
