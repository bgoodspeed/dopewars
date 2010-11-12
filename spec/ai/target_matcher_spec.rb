# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

describe TargetMatcher do
  before(:each) do
    @target_matcher = TargetMatcher.new("Enemy")
    @non_enemy_matcher = TargetMatcher.new("Foo")
  end

  it "should discern enemy targets" do
    TargetMatcher.new("enemy").target_is_enemy?.should be_true
    TargetMatcher.new("else").target_is_enemy?.should be_false
  end


  it "should be able to tell if two entities are enemies" do
    @target_matcher.is_enemy_of?(monster,hero).should be_true
    @target_matcher.is_enemy_of?(monster,monster).should be_false
    @target_matcher.is_enemy_of?(hero,hero).should be_false
  end

  it "should be able to determine if it matches" do
    @non_enemy_matcher.matches?(hero, hero).should be_true
    @target_matcher.matches?(monster, hero).should be_true
    @target_matcher.matches?(monster, monster).should be_false
  end

  def monster
    mock("monster")
  end

  def hero
    Hero.new
  end

end

