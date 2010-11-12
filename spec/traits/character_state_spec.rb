
require 'spec/rspec_helper'

describe CharacterState do
  include DomainMocks

  before(:each) do
    @attributes = mock_attributes
    @state = CharacterState.new(@attributes, 0, 1, 1, [], 3)
    @state2 = CharacterState.new(@attributes, 0, 1, 1, [], 3)
  end

  it "should store current attributes" do
    @state.current_hp.should == 1
    @state.current_mp.should == 1
  end
  it "should define deadness" do
    @state.dead?.should be_false
    @state.current_hp=0
    @state.dead?.should be_true
  end

  it "should take damage" do
    @state.take_damage(1)
    @state.current_hp.should == 0
  end

  it "should gain experience" do
    @state.gain_experience(42)
    @state.gain_experience(11)
    @state.experience.should == 53
  end

  it "should lose level points" do
    @state.level_points.should == 3
    @state.subtract_level_points(2)
    @state.level_points.should == 1
  end

  it "should add effects from other states" do
    @state.add_effects(@state2)
    @state.add_effects(@state2)
    @state.current_hp.should == 3
  end

  it "should get damage" do
    stub_strength(@state.attributes, 15)
    @state.damage.should == 15
  end

  it "should be json ified" do
    @state.json_params.should be_an_instance_of Array
  end
end
