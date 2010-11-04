# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

describe Mission do
  include DomainMocks
  before(:each) do
    @mission = Mission.new(:test_mission, "not described",[], [],[])
  end

  

  it "should have an id token" do
    @mission.id_token.should be_an_instance_of Symbol
  end
  it "should have description" do
    @mission.description.should be_an_instance_of String
  end
  it "should have pre-requisites" do
    @mission.prerequisites.should be_an_instance_of Array
  end
  it "should have objectives" do
    @mission.objectives.should be_an_instance_of Array
  end
  it "should have rewards" do
    @mission.rewards.should be_an_instance_of Array
  end

  it "should be available when all prerequisites are completed" do
    mission_with_prerequisites([]).available?.should be_true
    mission_with_prerequisites([mock_achieved_milestone]).available?.should be_true
    mission_with_prerequisites([mock_achieved_milestone,
       mock_achieved_milestone, mock_achieved_milestone]).available?.should be_true

    mission_with_prerequisites([mock_missed_milestone]).available?.should be_false
    mission_with_prerequisites([mock_achieved_milestone,
                                mock_missed_milestone]).available?.should be_false
    
  end

  def mission_with_prerequisites(prereqs)
    Mission.new(:test_prereqs_mission, "unset", prereqs, nil, nil)
  end
  def mission_with_objectives(objectives)
    Mission.new(:test_objectives_missions, "unset", nil, objectives, nil)
  end

  def mock_milestone
    m = mock("milestone")
    m
  end

  def mock_achieved_milestone(achieved=true)
    m = mock_milestone
    m.stub!(:achieved?).and_return achieved
    m
  end
  
  def mock_missed_milestone
    mock_achieved_milestone(false)
  end


  it "should be completed when all objectives are achieved" do
    mission_with_objectives([]).completed?.should be_true
    mission_with_objectives([mock_achieved_milestone]).completed?.should be_true
    mission_with_objectives([mock_achieved_milestone,
                             mock_achieved_milestone]).completed?.should be_true
                         
    mission_with_objectives([mock_missed_milestone]).completed?.should be_false
    mission_with_objectives([mock_achieved_milestone,
        mock_missed_milestone]).completed?.should be_false
  end

end

