# To change this template, choose Tools | Templates
# and open the template in the editor.

class EventSystem
  extend Forwardable
  attr_accessor :queue, :clock, :helper
  def_delegators :@clock, :lifetime
  def_delegators :@helper, :non_menu_hooks, :menu_active_hooks, :menu_hooks, :battle_active_hooks
  def initialize(clock, queue, helper)
    @clock = clock
    @queue = queue
    @helper = helper
  end
end
