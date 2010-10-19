# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

describe ConditionMatcher do
  before(:each) do
    @condition_matcher = ConditionMatcher.new("Any")
  end

  #TODO this class is not yet implemented
  it "currently always matches" do
    @condition_matcher.matches?(:a,:b).should be_true
  end
end

