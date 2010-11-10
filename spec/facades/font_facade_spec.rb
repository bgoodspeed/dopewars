
require 'spec/rspec_helper'

describe FontFacade do
  before(:each) do
    @font_facade = MusicFactory.new.load_font("FreeSans.ttf")
  end

  it "should be renderable" do
    @font_facade.respond_to?(:render).should be_true
  end
end
