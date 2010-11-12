
require 'spec/rspec_helper'

class FakeJsonEntity
  include JsonHelper
  def json_params
    [:json1, :json2]
  end
end

describe JsonHelper do
  include MethodDefinitionMatchers

  it "should define json_create and to_json on inclusion" do
    FakeJsonEntity.should define(:json_create)
    FakeJsonEntity.new.should define(:to_json)
  end

  it "should serialize with to_json" do
    FakeJsonEntity.new.to_json.should == "{\"data\":[\"json1\",\"json2\"],\"json_class\":\"FakeJsonEntity\"}"
    include JsonHelper
    self.to_json.should be_an_instance_of String
  end

end
