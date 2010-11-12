
require 'spec/rspec_helper'

describe Blocking do
  before(:each) do
    @blocking = Blocking.new
  end

  it "should block" do
    @blocking.is_blocking?.should be_true
  end
end
