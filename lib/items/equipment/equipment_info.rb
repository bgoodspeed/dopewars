
class EquipmentInfo
  def initialize(slot, equipped)
    @slot = slot
    @equipped = equipped
  end

  def to_s
    equipment_name = @equipped.nil? ? "empty" : @equipped.name
    "#{@slot}: #{equipment_name}"
  end
end

