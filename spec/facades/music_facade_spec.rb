
require 'spec/rspec_helper'

describe MusicFacade do
  include MethodDefinitionMatchers

  before(:each) do
    @music_facade = MusicFactory.new.load_music("bonobo-gypsy.mp3")
  end

  it "should meet the music api" do
    @music_facade.should define(:play)
    @music_facade.should define(:pause)
    @music_facade.should define(:playing?)
  end
end
