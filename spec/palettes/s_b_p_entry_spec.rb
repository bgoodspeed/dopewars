
require 'spec/rspec_helper'

describe SBPEntry do
  before(:each) do
    @entry = SBPEntry.new([1,2], :foo)
  end

  it "should have offsets and actionable" do
    @entry.offsets.should == [1,2]
    @entry.actionable.should == :foo
  end
end
