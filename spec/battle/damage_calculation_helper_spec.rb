# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

describe DamageCalculationHelper do
  include MockeryHelp
  @@SOME_DAMAGE_VALUE = 12

  before(:each) do
    @damage_calculation_helper = DamageCalculationHelper.new
  end

  it "should be able to calculate damage" do #TODO this is a naive damage calc algo
    src = mocking(:damage => @@SOME_DAMAGE_VALUE)
    @damage_calculation_helper.calculate_damage(src, nil).should == @@SOME_DAMAGE_VALUE
  end

end

