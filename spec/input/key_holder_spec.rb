
require 'spec/rspec_helper'

describe KeyHolder do
  before(:each) do
    @key_holder = KeyHolder.new
  end

  it "should start empty" do
    @key_holder.keys.should == []
  end
  it "should add and delete keys" do
    @key_holder.add_key(:monkey)
    @key_holder.keys.should == [:monkey]
    @key_holder.delete_key(:monkey)
    @key_holder.keys.should == []
  end
end
