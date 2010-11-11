
class GameInternalsFactory
  def make_event_system(game, always_on_hooks, menu_killed_hooks, menu_active_hooks, battle_hooks, battle_layer_hooks, player_hooks, npc_hooks)
    EventSystem.new(make_clock, make_queue, make_event_hooks(game, always_on_hooks, menu_killed_hooks, menu_active_hooks, battle_hooks, battle_layer_hooks, player_hooks, npc_hooks))
  end

  def make_event_manager
    EventManager.new
  end

  def make_screen
    #@screen = Screen.open( [640, 480] )
    screen = ScreenFacade.new([@@SCREEN_X, @@SCREEN_Y])
    screen.title = @@GAME_TITLE
    screen
  end
  def make_clock
    clock = ClockFacade.new()
    clock.target_framerate = 50
    clock.calibrate
    clock.enable_tick_events
    clock
  end

  def make_queue
    queue = EventQueueFacade.new()
    queue.enable_new_style_events
    queue.ignore_mouse_movement

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

  def make_attribution
    CharacterAttributionFactory.new.make_attribution
  end

  def make_hero(name, weapon, default_start_pts=@@HERO_START_BATTLE_PTS, default_rate=@@HERO_BATTLE_PTS_RATE, attr=make_attribution)
    Hero.new(name,  weapon, default_start_pts, default_rate, attr)
  end

  def make_player(screen, universe, game)
    #@player = Ship.new( @screen.w/2, @screen.h/2, @topomap, pallette, @terrainmap, terrain_pallette, @interactmap, interaction_pallette, @bgsurface )
    hero = make_hero("hero", SwungWorldWeapon.new(interaction_pallette))
    hero2 = make_hero("cohort", ShotWorldWeapon.new(interaction_pallette))
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

  def make_world(bg_filename, inter_filename, pal, inter_pal, bgm)
    WorldStateFactory.build_world_state(bg_filename,inter_filename, pal, inter_pal, @@BGX, @@BGY, [], bgm)
  end

  def make_world1
    bgm = BackgroundMusic.new("bonobo-time_is_the_enemy.mp3")
    make_world("world1_bg","world1_interaction", pallette, interaction_pallette,bgm)
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
    make_world("world2_bg","world2_interaction", pallette_160,  interaction_pallette_160, BackgroundMusic.new("bonobo-gypsy.mp3"))
  end
  def make_world3
    make_world("world3_bg","world3_interaction", pallette,  interaction_pallette,BackgroundMusic.new("bonobo-gypsy.mp3"))
  end

  def make_event_hooks(game, always_on_hooks, menu_killed_hooks, menu_active_hooks, battle_hooks, battle_layer_hooks, player_hooks, npc_hooks)
    event_helper = EventHelper.new(game, always_on_hooks, menu_killed_hooks, menu_active_hooks, battle_hooks, battle_layer_hooks, player_hooks, npc_hooks)
    event_helper
  end


  def make_sound_effects
    SoundEffectSet.new(["battle-start.ogg", "laser.ogg", "warp.ogg", "treasure-open.ogg"])
  end

  def tile(color)
    s = SurfaceFactory.new.make_surface([160,160])
    s.fill(color)
    s
  end

  def cisbp(conf, content)
    CISBPEntry.new(conf,content)
  end

  def cisbp_standard_treasure_box(item)
    cisbp(["treasure-boxes.png",4,4],Treasure.new(item))
  end

  def interaction_pallette
    pal = CompositeInteractableSurfaceBackedPallette.new([["treasure-boxes.png", 32,32], ["weapons-32x32.png", 32,32]])
#XXX note mixing sizes in a composite does not work well, ..
    pal['O'] = cisbp(["treasure-boxes.png",4,7],OpenTreasure.new("O"))
    pal['T'] = cisbp_standard_treasure_box(GameItemFactory.potion)
    pal['E'] = cisbp(["weapons-32x32.png", 1,0],Treasure.new(GameItemFactory.sword))
    pal['F'] = cisbp_standard_treasure_box(GameItemFactory.sword)
    pal['m'] = cisbp(["treasure-boxes.png",1,1],WarpPoint.new(1, 120, 700))
    pal['w'] = cisbp(["treasure-boxes.png",1,1],WarpPoint.new(1, 1020, 700))
#    pal['W'] = ISBPEntry.new([1,1],WarpPoint.new(0, 1200, 880))

    pal
  end
  def isbp(conf, content)
    ISBPEntry.new(conf, content)
  end

  def isbp_standard_treasure_box(item)
    isbp([4,4], Treasure.new(item))
  end

  def interaction_pallette_160
    pal = InteractableSurfaceBackedPallette.new("treasure-boxes-160.png", 160,160)

    pal['O'] = isbp([4,7],OpenTreasure.new("O"))
    pal['1'] = isbp_standard_treasure_box(GameItemFactory.potion)
    pal['2'] = isbp_standard_treasure_box(GameItemFactory.antidote)
    pal['3'] = isbp_standard_treasure_box(GameItemFactory.potion)
    pal['J'] = isbp([1,1],WarpPoint.new(2, 120, 700))
    pal['w'] = isbp([1,1],WarpPoint.new(1, 1020, 700))
    pal['W'] = isbp([1,1],WarpPoint.new(0, 1200, 880))

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
