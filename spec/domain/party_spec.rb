
require 'spec/rspec_helper'

describe Party do
  include DomainMocks
  before(:each) do
    @hero1 = mock_hero
    @hero2 = mock_hero
    @party = Party.new([@hero1, @hero2], @inventory)
  end

  it "should have a leader" do
    @party.leader.should == @hero1
  end

  it "should support earn/spend on money" do
    @party.earn(200)
    @party.earn(20)
    @party.earn(2)
    @party.money.should == 222
    @party.spend(111)
    @party.money.should == 111
  end

  it "should support dead queries -- only dead when all are dead" do
    stub_dead(@hero1)
    stub_dead(@hero2)
    @party.dead?.should be_true
  end
  it "should support dead queries -- one living is enough" do
    stub_dead(@hero1)
    stub_dead(@hero2, false)
    @party.dead?.should be_false
  end

  it "should give readiness" do
    expect_add_readiness(@hero1)
    expect_add_readiness(@hero2)
    @party.add_readiness(3)
  end

  it "should give experience" do
    expect_gain_experience(@hero1,3)
    expect_gain_experience(@hero2,3)
    @party.gain_experience(3)
  end

  it "should support collect" do
    names = @party.collect {|m| m.name}
    names.should == ["heromockman", "heromockman"]
  end

  it "should be json ified" do
    @party.json_params.should be_an_instance_of Array
  end
end
