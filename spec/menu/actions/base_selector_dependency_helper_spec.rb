
require 'spec/rspec_helper'


class FakeSelectorDependency
  include BaseSelectorDependencyHelper
  
end

describe BaseSelectorDependencyHelper do
  include MethodDefinitionMatchers
  
  before(:each) do
    @helper = FakeSelectorDependency.new
  end

  it "should define methods on inclusio" do
    @helper.should define(:dependencies)
    @helper.should define(:name)
    @helper.should define(:game)
    @helper.should define(:element_at)
  end
end
