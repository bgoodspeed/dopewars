# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

describe MissionArchive do
  include DomainMocks
  before(:each) do
    @game = mock_game
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
end

