
require 'spec/rspec_helper'

describe SoundFacade do
  before(:each) do
    @sound_facade = MusicFactory.new.load_sound("battle-start.ogg")
  end

  it "should support the sound api" do
    @sound_facade.respond_to?(:play).should be_true
  end
end
