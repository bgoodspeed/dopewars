
require 'spec/rspec_helper'

describe WorldState do
  include MethodDefinitionMatchers

  before(:each) do
    @world_state = WorldState.new(@topointerp, @interinterp, [], nil, @bgm)
  end

  it "should define methods" do
    @world_state.should define(:background_music)
  end
end
