
require 'spec/rspec_helper'

describe QuitRequestedFacade do
  before(:each) do
    @quit_requested_facade = QuitRequestedFacade.new
  end

  it "should give a type" do
    @quit_requested_facade.should_not be_nil
    QuitRequestedFacade.quit_request_type.should be_an_instance_of Class
  end
end
