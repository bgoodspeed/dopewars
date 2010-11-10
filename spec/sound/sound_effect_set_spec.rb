
require 'spec/rspec_helper'

describe SoundEffectSet do
  before(:each) do
    @sounds = SoundEffectSet.new(["battle-start.ogg"])
  end

  it "should be playable" do
    @sounds.play_sound_effect(SoundEffect::BATTLE_START)
  end
end
