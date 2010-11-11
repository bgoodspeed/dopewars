
require 'spec/rspec_helper'

describe BackgroundMusic do
  include DomainMocks
  
  before(:each) do
    @background_music = BackgroundMusic.new("bonobo-gypsy.mp3")
    @background_music.music = mock("music")
  end

  it "should build from the filename" do
    BackgroundMusic.new("bonobo-gypsy.mp3").music.should be_an_instance_of(MusicFacade)
  end

  it "should be able to know when it's playing" do
    stub_music_playing(@background_music.music)
    expect_pause(@background_music.music)
    @background_music.play_pause
  end
  
  it "should be able to know when it's not playing" do
    stub_music_playing(@background_music.music, false)
    expect_play(@background_music.music)
    @background_music.play_pause
  end

  it "should be able to fade out" do
    expect_fade_out(@background_music.music)
    @background_music.fade_out_bg_music
  end
  it "should be able to fade in" do
    expect_play(@background_music.music)
    @background_music.fade_in_bg_music
  end

end
