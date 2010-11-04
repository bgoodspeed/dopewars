# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

describe MissionDependencyMilestone do
  include DomainMocks

  before(:each) do
    @game = mock_game
    @mission_dependency_milestone = MissionDependencyMilestone.new(@game, :mission_id)
  end

  it "should ask the game if the mission with the id given has been accomplished - true" do
    @game.should_receive(:mission_achieved?).with(:mission_id).and_return true
    @mission_dependency_milestone.achieved?.should be_true
  end
  
  it "should ask the game if the mission with the id given has been accomplished - false" do
    @game.should_receive(:mission_achieved?).with(:mission_id).and_return false
    @mission_dependency_milestone.achieved?.should be_false
  end
end

