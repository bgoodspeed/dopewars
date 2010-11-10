
require 'spec/rspec_helper'

describe EventSystem do
  include DelegationMatchers
  before(:each) do
    @event_system = EventSystem.new(nil, nil, nil)
  end

  it "should delegate lifetime to clock" do
    @event_system.should delegate_to({:lifetime => []}, {:clock => :lifetime})
  end
  it "should delegate hook methods to helper" do
    @event_system.should delegate_to({:non_menu_hooks => []}, {:helper => :non_menu_hooks})
    @event_system.should delegate_to({:menu_active_hooks => []}, {:helper => :menu_active_hooks})
    @event_system.should delegate_to({:menu_hooks => []}, {:helper => :menu_hooks})
    @event_system.should delegate_to({:battle_active_hooks => []}, {:helper => :battle_active_hooks})
  end
end
