
require 'spec/rspec_helper'

class FakeResourceLoader
  include ResourceLoader
end

describe ResourceLoader do
  include MethodDefinitionMatchers
  
  before(:each) do
    @resource_loader = FakeResourceLoader.new
  end

  it "should be able to load things" do
    @resource_loader.should define(:load_music)
  end
end
