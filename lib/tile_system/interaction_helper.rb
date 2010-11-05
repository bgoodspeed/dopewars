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

  def interact_with_current_tile(game, tilex, tiley, this_tile_interacts)
    this_tile_interacts.activate(game, game.player, game.universe.current_world, tilex, tiley)
  end

  def interact_with_dialog
    @universe.dialog_layer.toggle_activity
  end

  def interact_with_facing_tile(game, facing_tilex, facing_tiley, facing_tile_interacts)
    facing_tile_interacts.activate(game, game.player, game.universe.current_world, facing_tilex, facing_tiley)
  end

  def interact_with_npc(game, interactable_npcs)
    npc = interactable_npcs[0] #TODO what if there are multiple npcs to interact w/? one at a time? all of them?
    npc.interact(game, game.universe, game.player) #TODO change the expected signature for interact and make interactable api tests
  end

  def interact_with_facing(game, px,py)
    if game.universe.dialog_layer.active
      puts "confirming/closing/paging dialog"
      interact_with_dialog
      return if @policy.return_after_dialog
    end

    puts "you are facing #{@facing}"
    tilex = game.universe.current_world.x_offset_for_interaction(px)
    tiley = game.universe.current_world.y_offset_for_interaction(py)
    this_tile_interacts = game.universe.current_world.interaction_interpreter.interpret(tilex, tiley)
    facing_tile_interacts = false

    if this_tile_interacts
      puts "you can interact with the current tile"
      interact_with_current_tile(game, tilex, tiley, this_tile_interacts)
      return if @policy.return_after_current
    end

    if @facing == :down
      facing_tilex = tilex
      facing_tiley = tiley + 1
      facing_tile_dist = (game.universe.current_world.interaction_interpreter.top_side(tiley + 1) - py).abs
    end
    if @facing == :up
      facing_tilex = tilex
      facing_tiley = tiley - 1
      facing_tile_dist = (game.universe.current_world.interaction_interpreter.bottom_side(tiley - 1) - py).abs
    end
    if @facing == :left
      facing_tilex = tilex - 1
      facing_tiley = tiley
      facing_tile_dist = (game.universe.current_world.interaction_interpreter.right_side(tilex - 1) - px).abs
    end
    if @facing == :right
      facing_tilex = tilex + 1
      facing_tiley = tiley
      facing_tile_dist = (game.universe.current_world.interaction_interpreter.left_side(tilex + 1) - px).abs
    end

    facing_tile_interacts = game.universe.current_world.interaction_interpreter.interpret(facing_tilex, facing_tiley)
    facing_tile_close_enough = facing_tile_dist < @@INTERACTION_DISTANCE_THRESHOLD

    if facing_tile_close_enough and facing_tile_interacts
      puts "you can interact with the facing tile in the #{@facing} direction, it is at #{facing_tilex} #{facing_tiley}"
      interact_with_facing_tile(game, facing_tilex, facing_tiley, facing_tile_interacts)

      return if @policy.return_after_facing
    end

    interactable_npcs = game.universe.current_world.npcs.select {|npc| npc.nearby?(px,py, @@INTERACTION_DISTANCE_THRESHOLD, @@INTERACTION_DISTANCE_THRESHOLD)  }
    unless interactable_npcs.empty?
      puts "you can interact with the npc: #{interactable_npcs[0]}"
      interact_with_npc(game, interactable_npcs)
    end

  end
end