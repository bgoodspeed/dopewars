
require 'spec/rspec_helper'

class FakeOwner
  def foo
    "bar"
  end
end

describe MethodActionFacade do
  before(:each) do
    @method_action_facade = MethodActionFacade.new(:foo)
  end

  it "should know what method action to invoke" do
    @method_action_facade.perform(FakeOwner.new, nil).should == "bar"
  end
end
