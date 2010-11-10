
require 'spec/rspec_helper'

describe CISBPEntry do
  before(:each) do
    @c_i_s_b_p_entry = CISBPEntry.new([[1,2], [3, 4]], nil)
  end

  it "should parse config" do
    @c_i_s_b_p_entry.offsets.should == [[3,4]]
  end
end
