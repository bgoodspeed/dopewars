
require 'spec/rspec_helper'

class FakeJsonEntity
  include JsonHelper
end

describe JsonHelper do
  include MethodDefinitionMatchers

  it "should define json_create and to_json on inclusion" do
    FakeJsonEntity.should define(:json_create)
    FakeJsonEntity.new.should define(:to_json)
  end


end
