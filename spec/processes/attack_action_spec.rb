
require 'spec/rspec_helper'

describe AttackAction do
  include DomainMocks
  
  before(:each) do
    @src = mock_hero
    @dest = mock_hero
    @attack_action = AttackAction.new
  end

  def stub_damage_query(m, dam=3)
    m.stub!(:damage).and_return dam
    dam
  end

  def expect_damage_taken(m, dam)
    m.should_receive(:take_damage).with(dam)
  end
  it "should be described" do
    dam = stub_damage_query(@src)
    expect_damage_taken(@dest, dam)
    expect_readiness_consumed(@src)
    @attack_action.perform(@src, @dest)
  end
end
