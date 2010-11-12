
class Party
  extend Forwardable
  def_delegators :@inventory, :add_item, :gain_inventory, :inventory_info, 
    :inventory_item_at, :inventory_count
  def_delegators :leader, :world_weapon
  attr_reader :members, :inventory, :money
  def initialize(members, inventory, money=0)
    @members = members
    @inventory = inventory
    @money = money
  end

  def collect
    @members.collect {|member| yield member}
  end
  def earn(amount)
    @money += amount
  end

  def spend(amount)
    raise InsufficientMoneyException if amount > @money
    @money -= amount
  end

  def leader
    @members.first
  end
  def add_readiness(pts)
    @members.each {|member| member.add_readiness(pts) }
  end
  def gain_experience(pts)
    @members.each {|member| member.gain_experience(pts) }
  end

  def dead?
    living_members = @members.select {|m| !m.dead?}
    living_members.empty?
  end

  include JsonHelper
  def json_params
    [ @members, @inventory]
  end
end
