
require 'spec/rspec_helper'

describe TextRenderingConfig do
  before(:each) do
    @text_rendering_config = TextRenderingConfig.new(1,2,3,4)
  end

  it "should bind constants and factors from constructor" do
    @text_rendering_config.xc.should == 1
    @text_rendering_config.xf.should == 2
    @text_rendering_config.yc.should == 3
    @text_rendering_config.yf.should == 4
  end
end
