
require 'spec/rspec_helper'

describe BackgroundMusic do
  before(:each) do
    @background_music = BackgroundMusic.new("bonobo-gypsy.mp3")
  end

  it "should be described" do
    @background_music.music.should be_an_instance_of(MusicFacade)
  end
end
