
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
  it "should clear keys" do
    @key_holder.add_key(:monkey)
    @key_holder.add_key(:butler)
    @key_holder.clear_keys
    @key_holder.keys.should == []
  end

  it "should set timed keypresses in ticks" do
    @key_holder.set_timed_keypress(:up, 2)
    @key_holder.keys.should == [:up]
    @key_holder.update_timed_keys(0.02)
    @key_holder.update_timed_keys(0.02)
    @key_holder.keys.should == []
  end

  it "should set timed keypresses in ms" do
    @key_holder.set_timed_keypress_in_ms(:up, 200)
    @key_holder.keys.should == [:up]
    @key_holder.update_timed_keys(0.1)
    @key_holder.update_timed_keys(0.1)
    @key_holder.keys.should == []
  end
  
end
