
require 'spec/rspec_helper'

describe SurfaceFacade do
  include MethodDefinitionMatchers
  before(:each) do
    @surface_facade = SurfaceFacade.new([2,2])
  end

  it "should meet the surface api" do
    @surface_facade.should define(:blit)
  end
end
