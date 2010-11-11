
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

  def expect_data_query(topo, x,y)
    topo.should_receive(:data_at).with(x,y).and_return :data_at_x_y
    :data_at_x_y
  end
  def expect_pallette_conversion(pal, datum)
    pal.should_receive(:[]).with(datum).and_return :converted
    :converted
  end

  before(:each) do
    @topo = mock_topo_map
    @pallette = mock_pallette
    @interpreted_map = InterpretedMap.new(@topo, @pallette)
  end

  it "can interpret" do
    datum = expect_data_query(@topo, 0, 0)
    expect_pallette_conversion(@pallette, datum)
    @interpreted_map.interpret(0, 0)
  end
end
