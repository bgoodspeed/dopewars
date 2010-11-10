
require 'spec/rspec_helper'

describe AlwaysDownMonsterKeyHolder do
  before(:each) do
    @key_holder = AlwaysDownMonsterKeyHolder.new(:left)
  end

  it "should find first/only key" do
    @key_holder.first.should == :left
  end
end
