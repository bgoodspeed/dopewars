
require 'spec/rspec_helper'

describe InteractionHelper do
  include DomainMocks

  before(:each) do
    @game = mock_game
    @policy = InteractionPolicy.immediate_return
    @interaction_helper = InteractionHelper.new(@game, @policy)
  end

  it "should be interactable" do
    
    @interaction_helper.interact_with_facing(@game, 123, 456)
  end
end
