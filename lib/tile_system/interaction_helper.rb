class InteractionHelper
  @@INTERACTION_DISTANCE_THRESHOLD = 80 #XXX tweak this, currently set to 1/2 a tile

  attr_accessor :facing
  def initialize(game, policy)
    @game = game
    @player = game.player
    @universe = game.universe
    @facing = :down
    @policy = policy
  end

  def interact_with_tile(game, tilex, tiley, tile)
    tile.activate(game, game.player, game.universe.current_world, tilex, tiley)
  end

  def interact_with_dialog(layer)
    layer.toggle_activity
  end
 
  def interact_with_npc(game, interactable_npcs)
    npc = interactable_npcs[0] #TODO what if there are multiple npcs to interact w/? one at a time? all of them?
    npc.interact(game, game.universe, game.player) #TODO change the expected signature for interact and make interactable api tests
  end

  def calculate_facing(stable_dirs, negative_dirs, tile)
    if stable_dirs.include?(@facing)
      tile
    elsif negative_dirs.include?(@facing)
      tile - 1
    else
      tile
    end
  end
  def facing_tilex_for(tile)
    calculate_facing([:down,:up], [:left], tile)
  end

  def facing_tiley_for(tile)
    calculate_facing([:left, :right], [:up], tile)
  end

  def facing_tile_distance_for(game, tilex, tiley, px, py)
    facing_tile_dist = nil
    if @facing == :down
      facing_tile_dist = (game.universe.current_world.interaction_interpreter.top_side(tiley + 1) - py).abs
    elsif @facing == :up
      facing_tile_dist = (game.universe.current_world.interaction_interpreter.bottom_side(tiley - 1) - py).abs
    elsif @facing == :left
      facing_tile_dist = (game.universe.current_world.interaction_interpreter.right_side(tilex - 1) - px).abs
    else
      facing_tile_dist = (game.universe.current_world.interaction_interpreter.left_side(tilex + 1) - px).abs
    end
    facing_tile_dist
  end

  def attempt_interaction_with_dialog(layer)
    return false unless layer.active
    interact_with_dialog(layer)
    true
  end

  def attempt_interaction_with_tile(game, tilex, tiley, tile)
    return false unless tile
    interact_with_tile(game, tilex, tiley, tile)
    true
  end

  def attempt_interaction_with_facing(game, tilex, tiley, tile, close_enough)
    return false unless tile and close_enough
    interact_with_tile(game, tilex, tiley, tile)
    true
  end
  
  def attempt_interaction_with_npcs(game, npcs)
    return false if npcs.empty?
    interact_with_npc(game, npcs)
    true
  end

  def interact_with_facing(game, px,py)
    puts "mapped key to interaction helper"
    return if attempt_interaction_with_dialog(game.universe.dialog_layer) and @policy.return_after_dialog

    tilex = game.universe.current_world.x_offset_for_interaction(px)
    tiley = game.universe.current_world.y_offset_for_interaction(py)
    this_tile_interacts = game.universe.current_world.interaction_interpreter.interpret(tilex, tiley)
    facing_tile_interacts = false
    
    return if attempt_interaction_with_tile(game, tilex, tiley, this_tile_interacts) and @policy.return_after_current

    facing_tilex = facing_tilex_for(tilex)
    facing_tiley = facing_tiley_for(tiley)
    facing_tile_dist = facing_tile_distance_for(game, tilex, tiley, px, py)
    #puts "i am on #{tilex},#{tiley}, i am facing #{@facing} -> #{facing_tilex}"
    facing_tile_interacts = game.universe.current_world.interaction_interpreter.interpret(facing_tilex, facing_tiley)
    facing_tile_close_enough = facing_tile_dist < @@INTERACTION_DISTANCE_THRESHOLD

    return if attempt_interaction_with_facing(game, facing_tilex, facing_tiley, facing_tile_interacts, facing_tile_close_enough) and @policy.return_after_facing

    interactable_npcs = game.universe.current_world.npcs.select {|npc| npc.nearby?(px,py, @@INTERACTION_DISTANCE_THRESHOLD, @@INTERACTION_DISTANCE_THRESHOLD)  }
    attempt_interaction_with_npcs(game, interactable_npcs)

  end
end