
require 'spec/rspec_helper'

describe BattleParticipantCursorTextRenderingConfig do
  include DomainMocks
  before(:each) do
    @game = mock_game
    @config = BattleParticipantCursorTextRenderingConfig.new([String], 1,2,3,4)
  end

  it "should bind xc et al" do
    @config.xc.should == 1
    @config.xf.should == 2
    @config.yc.should == 3
    @config.yf.should == 4
  end

  it "should be to tell if a given entity matches" do
    @config.matches_menu_action?("str").should be_true
    @config.matches_menu_action?(:symbol).should be_false
  end

  it "should be able to calculate cursor offsets at -- matching" do
    expect_current_battle_participant_offset(@game, :posn)
    @config.cursor_offsets_at(:posn, @game, "menuaction").should == :expected_offset
  end
  it "should be able to calculate cursor offsets at -- not matching" do
    @config.cursor_offsets_at(42, @game, :notamenuaction).should be_an_instance_of Array
  end
end
