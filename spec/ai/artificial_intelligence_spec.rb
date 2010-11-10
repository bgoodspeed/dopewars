# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'forwardable'
require 'lib/ai/artificial_intelligence'
require 'spec/rspec_helper'

describe ArtificialIntelligence do
  include DelegationMatchers


  before(:each) do
    @artificial_intelligence = ArtificialIntelligence.new(nil, nil)
  end
  it "should delegate updates to follow" do
    @artificial_intelligence.should delegate_to({:update => [1]}, {:follow_strategy => :update})
  end
  it "should delegate turns to battle strategy" do
    @artificial_intelligence.should delegate_to({:take_battle_turn => [1]}, {:battle_strategy => :take_battle_turn})
  end
  
end

