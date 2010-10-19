# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'


describe BattleTactic do
  include DelegationMatchers
  before(:each) do

    @battle_tactic = BattleTactic.new("Enemy : Any -> Attack")
  end

  #TODO more types are needed
  it "should parse from strings" do
    @battle_tactic.parse("Self : Any -> Attack")
    @battle_tactic.target.should be_a TargetMatcher
    @battle_tactic.action.should be_an ActionInvoker
    @battle_tactic.condition.should be_a ConditionMatcher
  end

  it "should delegate perform_on to action" do
    @battle_tactic.should delegate_to({:perform_on => [:src,:dest]}, {:action => :perform_on})
  end

  it "should delegate matches only when target matches" do
    tactic_with(mock_matches(true),mock_matches(true)).matches?(:a, :b).should be_true
    tactic_with(mock_matches(false),mock_matches(true)).matches?(:a, :b).should be_false
    tactic_with(mock_matches(false),mock_matches(false)).matches?(:a, :b).should be_false
    tactic_with(mock_matches(true),mock_matches(false)).matches?(:a, :b).should be_false
  end

  def tactic_with(target, cond)
    @battle_tactic.target = target
    @battle_tactic.condition = cond
    @battle_tactic
  end

  def mock_matches(val)
    m = mock
    m.stub!(:matches?).and_return(val)
    m
  end
end

