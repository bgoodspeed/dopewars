
class WorldState
  attr_accessor :topo_interpreter, :interaction_interpreter,:npcs, :background_surface, :background_music

  extend Forwardable
  def_delegator :@topo_interpreter, :update, :update_topo_map
  def_delegator :@topo_interpreter, :update, :update_topo_map
  def_delegator :@topo_interpreter, :can_walk_at?, :can_walk_on_background_at?
  def_delegator :@interaction_interpreter, :x_offset_for_world, :x_offset_for_interaction
  def_delegator :@interaction_interpreter, :y_offset_for_world, :y_offset_for_interaction
  def_delegator :@interaction_interpreter, :update, :update_interaction_map
  def_delegators :@topo_interpreter, :x_offset_for_world, :y_offset_for_world
  def_delegators :@interaction_interpreter, :blit_foreground
  def_delegator :@background_music, :play_pause, :toggle_bg_music
  def_delegators :@background_music, :fade_out_bg_music, :fade_in_bg_music

  def initialize(topointerp, interinterp, npcs, bgsurface, bgmusic)
    @topo_interpreter = topointerp
    @interaction_interpreter = interinterp
    @npcs = npcs
    @background_surface = bgsurface
    @background_music = bgmusic

    reblit_background unless bgsurface.nil?
  end

  def replace_pallettes(orig_world)
    @topo_interpreter = orig_world.topo_interpreter
    @interaction_interpreter.replace_pallette(orig_world.interaction_interpreter)
  end

  def reblit_background
    @topo_interpreter.blit_to(@background_surface)
  end

  def delete_monster(monster)
    @npcs -= [monster]
  end
  def add_npc(npc)
    @npcs += [npc]
  end

  def blit_world(screen, player)
    sx = screen.w
    sy = screen.h
    ext_x = sx/2
    ext_y = sy/2
    screen_left = player.px - ext_x
    screen_top = player.py - ext_y

    @background_surface.blit(screen, [0,0], [ screen_left,screen_top, sx, sy])
    blit_foreground(screen, player.px, player.py)

    @npcs.each {|npc|
      npc.draw(screen, player.px, player.py, sx, sy) if npc.nearby?(player.px, player.py, ext_x, ext_y)
    }
  end

  def replace_bgsurface(orig_world)
    @background_surface = orig_world.background_surface
  end
  def replace_bgmusic(orig_world)
    @background_music = orig_world.background_music
  end



  include JsonHelper
  def json_params
    [ nil, @interaction_interpreter, @npcs, nil,nil]
  end
end
