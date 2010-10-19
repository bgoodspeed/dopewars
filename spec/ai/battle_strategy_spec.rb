# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

module FakeTactics
  class FakeTactic
    attr_reader :performed
    def initialize
      @performed = false
    end
    def perform_on(a,b)
      @performed = true
    end
  end
  class AlwaysMatchingFakeTactic < FakeTactic
    def matches?(a,b)
      true
    end
  end

  class NeverMatchingFakeTactic < FakeTactic
    def matches?(a,b)
      false
    end
  end

  class OnlyMatchingFakeTactic < FakeTactic
    def initialize(what)
      @what = what
    end

    def matches?(a,b)
      b == @what
    end
  end

  class FakeBattle
    attr_reader :participants
    def initialize(m )
      @participants = m
    end
  end

  def only(what)
    OnlyMatchingFakeTactic.new(what)
  end
  def always
    AlwaysMatchingFakeTactic.new
  end
  def never
    NeverMatchingFakeTactic.new
  end

  def battle(m)
    FakeBattle.new(m)
  end
end


describe BattleStrategy do
  include FakeTactics
  before(:each) do
    @a1 = always
    @a2 = always
    @n1 = never
    @n2 = never
    @only_jim = only(:jim)
    @battle_strategy = BattleStrategy.new([@n1, @n2, @a1, @a2])
    @only_jim_strategy = BattleStrategy.new([@n1, @n2, @only_jim, @a1])
  end

  it "should evaluate the tactics in order" do
    tactical_match = @battle_strategy.first_matching_tactic([:bob, :jim], :alice)
    tactical_match.target.should == :bob
    tactical_match.tactic.should == @a1
    tactical_match.actor.should == :alice
  end
  
  it "should iterate through tactics first" do
    tactical_match = @only_jim_strategy.first_matching_tactic([:bob, :jim], :alice)
    tactical_match.target.should == :jim
    tactical_match.tactic.should == @only_jim
    tactical_match.actor.should == :alice
  end

  it "should invoke the action" do
    @battle_strategy.take_battle_turn(:alice, battle([:bob, :jim]))
    @a1.performed.should be_true
    @a2.performed.should be_false
    @n1.performed.should be_false
    @n2.performed.should be_false
  end
end

