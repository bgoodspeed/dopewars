
class EquipmentHolder
  def initialize
    @equipped = Hash.new
  end

  def equipped_on(slot)
    @equipped[slot]
  end

  def equip_on(slot, gear)
    @equipped[slot] = gear
  end

  def equip_in_slot_index(idx, gear)
    equip_on(slots[idx], gear)
  end

  def equipment_info
    slots.collect {|slot| EquipmentInfo.new(slot, equipped_on(slot))}
  end

  def slots
    [:head, :body, :feet, :left_hand, :right_hand]
  end
end
