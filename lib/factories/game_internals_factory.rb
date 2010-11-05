
class GameInternalsFactory
  include Rubygame
  include Rubygame::Events
  include Rubygame::EventActions
  include Rubygame::EventTriggers


  def make_screen
    #@screen = Screen.open( [640, 480] )
    screen = Screen.new([@@SCREEN_X, @@SCREEN_Y])
    screen.title = @@GAME_TITLE
    screen
  end
  def make_clock
    clock = Clock.new()
    clock.target_framerate = 50
    clock.calibrate
    clock.enable_tick_events
    clock
  end

  def make_queue
    queue = EventQueue.new()
    queue.enable_new_style_events

    queue.ignore = [MouseMoved]
    queue
  end

  def make_game_layers(screen, game)
    GameLayers.new(make_dialog_layer(screen, game), make_menu_layer(screen,game), make_battle_layer(screen, game), make_notifications_layer(screen, game))
  end
  def make_battle_layer(screen, game)
    BattleLayer.new(screen, game)
  end
  def make_notifications_layer(screen, game)
    NotificationsLayer.new(screen, game)
  end
  def make_dialog_layer(screen, game)
    DialogLayer.new(screen, game)
  end
  def make_menu_layer(screen,game)
    MenuLayer.new(screen,game)
  end
  def make_universe(worldstates, layers, sound_effects, game)
    Universe.new(0, worldstates , layers, sound_effects, game)
  end
  def make_hud(screen, player, universe)
    Hud.new :screen => screen, :player => player, :universe => universe
  end
  def make_player(screen, universe, game)
    #@player = Ship.new( @screen.w/2, @screen.h/2, @topomap, pallette, @terrainmap, terrain_pallette, @interactmap, interaction_pallette, @bgsurface )
    hero = Hero.new("hero",  SwungWorldWeapon.new(interaction_pallette), @@HERO_START_BATTLE_PTS, @@HERO_BATTLE_PTS_RATE, CharacterAttribution.new(
        CharacterState.new(CharacterAttributes.new(5, 5, 1, 0, 0, 0, 0, 0)),
        EquipmentHolder.new))
    hero2 = Hero.new("cohort", ShotWorldWeapon.new(interaction_pallette), @@HERO_START_BATTLE_PTS, @@HERO_BATTLE_PTS_RATE, CharacterAttribution.new(
        CharacterState.new(CharacterAttributes.new(5, 5, 1, 0, 0, 0, 0, 0)),
        EquipmentHolder.new))
    party_inventory = Inventory.new(255) #TODO revisit inventory -- should it have a maximum?
    party_inventory.add_item(1, GameItemFactory.potion)
    party_inventory.add_item(1, GameItemFactory.antidote) #TODO how to model status effects
    party_inventory.add_item(1, GameItemFactory.sword) #TODO how to model status effects
    party = Party.new([hero, hero2], party_inventory)
    hero_x_dim = 48
    hero_y_dim = 64
    #player_file = "Charactern8.png"
    player_file = "StickMan.PNG"
    ssx = screen.w/2
    ssy = screen.h/2
    posn = PositionedTileCoordinate.new(SdlCoordinate.new(ssx, ssy), SdlCoordinate.new(hero_x_dim, hero_y_dim))
    player = Player.new(posn, universe, party, player_file, ssx, ssy, game )

    player
    # Make event hook to pass all events to @player#handle().
  end
  def make_world1
    bgm = BackgroundMusic.new("bonobo-time_is_the_enemy.mp3")
    WorldStateFactory.build_world_state("world1_bg","world1_interaction", pallette, interaction_pallette, @@BGX, @@BGY, [], bgm)
  end

  def make_monster(player,universe)
    MonsterFactory.new.make_monster(player, universe)
  end

  def make_npc(player, universe)
    npcattrib = CharacterAttribution.new(
        CharacterState.new(CharacterAttributes.new(3, 0, 0, 0, 0, 0, 0, 0)),
        EquipmentHolder.new)
    npcai = ArtificialIntelligence.new(RepeatingPathFollower.new("LURD", 80), nil) #TODO maybe make a noop battle strategy just in case?
    #npcai = StaticPathFollower.new
    posn = PositionedTileCoordinate.new(SdlCoordinate.new(600,200), SdlCoordinate.new(48,64))
    TalkingNPC.new(player, universe, "i am an npc", "gogo-npc.png", posn, Inventory.new(255), npcattrib, npcai)
  end

  def make_world2
    WorldStateFactory.build_world_state("world2_bg","world2_interaction", pallette_160,  interaction_pallette_160, @@BGX, @@BGY, [], BackgroundMusic.new("bonobo-gypsy.mp3"))
  end
  def make_world3
    WorldStateFactory.build_world_state("world3_bg","world3_interaction", pallette,  interaction_pallette, @@BGX, @@BGY, [], BackgroundMusic.new("bonobo-gypsy.mp3"))
  end

  def make_event_hooks(game, always_on_hooks, menu_killed_hooks, menu_active_hooks, battle_hooks)
    event_helper = EventHelper.new(game, always_on_hooks, menu_killed_hooks, menu_active_hooks, battle_hooks)
    event_helper
  end


  def make_sound_effects
    SoundEffectSet.new(["battle-start.ogg", "laser.ogg", "warp.ogg", "treasure-open.ogg"])
  end

  def tile(color)
    s = Surface.new([160,160])
    s.fill(color)
    s
  end

  def interaction_pallette
    pal = CompositeInteractableSurfaceBackedPallette.new([["treasure-boxes.png", 32,32], ["weapons-32x32.png", 32,32]])
#XXX note mixing sizes in a composite does not work well, ..
    pal['O'] = CISBPEntry.new(["treasure-boxes.png",4,7],OpenTreasure.new("O"))
    pal['T'] = CISBPEntry.new(["treasure-boxes.png",4,4],Treasure.new(GameItemFactory.potion))
    pal['E'] = CISBPEntry.new(["weapons-32x32.png", 1,0],Treasure.new(GameItemFactory.sword))
    pal['F'] = CISBPEntry.new(["treasure-boxes.png",4,4],Treasure.new(GameItemFactory.sword))
    pal['m'] = CISBPEntry.new(["treasure-boxes.png",1,1],WarpPoint.new(1, 120, 700))

    pal['w'] = CISBPEntry.new(["treasure-boxes.png",1,1],WarpPoint.new(1, 1020, 700))
#    pal['W'] = ISBPEntry.new([1,1],WarpPoint.new(0, 1200, 880))

    pal
  end
  def interaction_pallette_160
    pal = InteractableSurfaceBackedPallette.new("treasure-boxes-160.png", 160,160)

    pal['O'] = ISBPEntry.new([4,7],OpenTreasure.new("O"))
    pal['1'] = ISBPEntry.new([4,4],Treasure.new(GameItemFactory.potion))
    pal['2'] = ISBPEntry.new([4,4],Treasure.new(GameItemFactory.antidote))
    pal['3'] = ISBPEntry.new([4,4],Treasure.new(GameItemFactory.potion))
    pal['J'] = ISBPEntry.new([1,1],WarpPoint.new(2, 120, 700))
    pal['w'] = ISBPEntry.new([1,1],WarpPoint.new(1, 1020, 700))
    pal['W'] = ISBPEntry.new([1,1],WarpPoint.new(0, 1200, 880))

    pal

  end
  def pallette
    pal = SurfaceBackedPallette.new("scaled-background-20x20.png", 20, 20)
    pal['G'] = SBPEntry.new([1,4], false)
    pal['M'] = SBPEntry.new([0,2], true)
    pal['g'] = SBPEntry.new([0,6], false)
    pal['O'] = SBPEntry.new([1,3], true) #TODO this should not be open treasure
    pal['T'] = SBPEntry.new([1,3], true) #TODO this should not be treasure
    pal['w'] = SBPEntry.new([0,5], false) #TODO this should not be warp
    pal['W'] = SBPEntry.new([0,5], false) #TODO this should not be warp
    pal

  end
  def pallette_160
    pal = Pallette.new(tile(:blue))
    pal['O'] = JsonLoadableSurface.new("open-treasure-on-grass-bg-160.png", true)
    pal['T'] = JsonLoadableSurface.new("treasure-on-grass-bg-160.png", true)
    pal['w'] = JsonLoadableSurface.new("water-bg-160.png", true)
    pal['W'] = JsonLoadableSurface.new("town-on-grass-bg-160.png", false)
    pal['M'] = JsonLoadableSurface.new("mountain-bg-160.png", true)
    pal['G'] = JsonLoadableSurface.new("grass-bg-160.png", false)
    pal['g'] = JsonLoadableSurface.new("real-grass-bg-160.png", false)
    pal
  end



end
