
class WorldStateFactory
  def self.build_world_state(bg_file, int_file, pallette, interaction_pallette, bgx, bgy, npcs, bgm)
    bgsurface = JsonSurface.new([bgx,bgy])
    bg = InterpretedMap.new(TopoMapFactory.build_map(bg_file, bgx, bgy), pallette)
    inter = InterpretedMap.new(TopoMapFactory.build_map(int_file, bgx, bgy), interaction_pallette)
    WorldState.new(bg, inter, npcs, bgsurface, bgm)
  end
end
