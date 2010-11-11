
require 'spec/rspec_helper'

describe BattleParticipantCursorTextRenderingConfig do
  before(:each) do
    @config = BattleParticipantCursorTextRenderingConfig.new([:foo], 1,2,3,4)
  end

  it "should bind xc et al" do
    @config.xc.should == 1
    @config.xf.should == 2
    @config.yc.should == 3
    @config.yf.should == 4
  end
end
