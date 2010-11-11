
require 'spec/rspec_helper'

describe InteractionPolicy do
  before(:each) do
    @true_policy = InteractionPolicy.new(true, true, true, true)
    @false_policy = InteractionPolicy.new(false, false, false, false)
  end

  it "should define return policy for key moments" do
    @true_policy.current.should be_true
    @true_policy.dialog.should be_true
    @true_policy.facing.should be_true
    @true_policy.npcs.should be_true

    @false_policy.current.should be_false
    @false_policy.dialog.should be_false
    @false_policy.facing.should be_false
    @false_policy.npcs.should be_false
  end
end
