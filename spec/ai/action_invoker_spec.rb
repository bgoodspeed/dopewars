# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'


describe ActionInvoker do
  include DelegationMatchers
  before(:each) do
    @action_invoker = ActionInvoker.new("attack")
  end

  it "should match strings and produce processes" do
    @action_invoker.action.should be_an AttackAction
    
    ActionInvoker.new("aTTacK").action.should be_an AttackAction
    ActionInvoker.new("ATTACK").action.should be_an AttackAction
    ActionInvoker.new("other").action.should be_nil
  end



  it "should be able to build processes from strings" do
    @action_invoker.build_from("attAck").should be_an AttackAction
    @action_invoker.build_from("other").should be_nil
  end

  it "should delegate to the action when called" do
    @action_invoker.should delegate_to({:perform_on => [1,2]}, {:action => :perform})
  end

  
end

