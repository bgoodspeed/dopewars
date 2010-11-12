# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

describe MissionArchive do
  include DomainMocks

  def mock_mission
    m = mock("mission")
    m.stub!(:id_token).and_return(:a_mission_id_token)
    m
  end

  before(:each) do
    @game = mock_game
    @mission = mock_mission
    @mission_archive = MissionArchive.new(@game)
  end

  it "should know which missions have been completed" do
    
  end

  it "should have access to all missions" do
    @mission_archive.all_missions.should be_an_instance_of Array
  end

  it "should filter available missions -- first friend not found means one less quest" do
    @game.should_receive(:mission_achieved?).with(:first_friend).and_return(false)

    ms = @mission_archive.missions
    ms.should be_an_instance_of Array

    ms.size.should == 2
  end
  it "should filter available missions" do
    @game.should_receive(:mission_achieved?).with(:first_friend).and_return(true)

    ms = @mission_archive.missions
    ms.should be_an_instance_of Array

    ms.size.should == 3
  end

  it "should tell if a mission is achieved" do
    @mission_archive.mission_achieved?(@mission.id_token).should be_false
    @mission_archive.mark_completed(@mission)
    @mission_archive.mission_achieved?(@mission.id_token).should be_true
  end
end

