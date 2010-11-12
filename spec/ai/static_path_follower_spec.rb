# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

describe StaticPathFollower do
  before(:each) do
    @static_path_follower = StaticPathFollower.new
  end

  it "should do nothing" do
    @static_path_follower.update(nil)
  end

  it "is json ified" do
    @static_path_follower.json_params.should be_an_instance_of Array
  end
end

