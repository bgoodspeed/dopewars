
require 'spec/rspec_helper'

describe MonsterFactory do
  include DomainMocks
  
  before(:each) do
    @player = mock_player
    @universe = mock_universe
    @monster_factory = MonsterFactory.new
  end

  it "should make monsters" do
    @monster_factory.make_monster(@player, @universe).should be_an_instance_of(Monster)
  end
end
