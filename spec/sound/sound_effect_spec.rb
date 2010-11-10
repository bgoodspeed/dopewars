
require 'spec/rspec_helper'

describe SoundEffect do
  before(:each) do
    @sound_effect = SoundEffect::BATTLE_START
  end

  it "should be a constant" do
    s1 = SoundEffect::TREASURE
    s2 = SoundEffect::WARP

    s1.should_not == s2
  end
  
end
