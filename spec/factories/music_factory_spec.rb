
require 'spec/rspec_helper'

describe MusicFactory do
  before(:each) do
    @music_factory = MusicFactory.new
  end

  it "should build music facades" do
    @music_factory.load_music("bonobo-gypsy.mp3").should be_an_instance_of(MusicFacade)
  end
end
