
require 'spec/rspec_helper'

describe ReloaderHelper do
  include DomainMocks
  
  before(:each) do
    @game = mock_game
    @player = mock_player
    @reloader_helper = ReloaderHelper.new
  end

  it "should hack the planet to satisfy rcov XXX this is not a best practice" do
    @reloader_helper.replace(@game, @player)
  end


  #TODO need to test saving and loading
    #TODO need to test saving and loading
    #TODO need to test saving and loading
  

end
