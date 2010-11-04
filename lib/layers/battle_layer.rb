
class BattleLayer < AbstractLayer
  include Rubygame
  include Rubygame::Events

  extend Forwardable
  def_delegators :@battle, :participants, :current_battle_participant_offset
  def_delegators :@game, :inventory
  attr_reader :battle, :text_rendering_helper
  include EventHandler::HasEventHandler
  def initialize(screen, game)
    super(screen, screen.w - 50, screen.h - 50)
    @layer.fill(:orange)
    @text_rendering_helper = TextRenderingHelper.new(@layer, @font)
    @battle = nil
    @game = game
    @battle_hud = BattleHud.new(@screen, @text_rendering_helper, @layer)
    
    @cursor_helper = CursorHelper.new([20,20]) #TODO these constants should be extracted
    make_magic_hooks({ClockTicked => :update})
  end
  def update( event )
    return unless @battle and !@battle.over?
    dt = event.seconds # Time since last update
    @battle.accumulate_readiness(dt)
  end

  def rebuild_menu
    @menu = TaskMenu.new(@game, [
        AttackBattleMenuAction.new(@game),
        UseBattleItemBattleMenuAction.new(@game),
        UseSkillBattleMenuAction.new(@game),
        FleeBattleMenuAction.new(@game) ])

    @end_menu = TaskMenu.new(@game, [
        AcceptBattleOutcomeMenuAction.new(@game)
      ])

  end
  def start_battle(game, universe, player, monster)
    @active = true
    @battle = Battle.new(game, universe, player, monster, self)
  end
  def end_battle
    @active = false
    @battle.end_battle
  end
  def menu_layer_config

    mlc = MenuLayerConfig.new
    mlc.main_menu_text = TextRenderingConfig.new(@@MENU_TEXT_INSET, @@MENU_TEXT_WIDTH, @layer.h - 125, 0)
    mlc.section_menu_text = TextRenderingConfig.new(@@MENU_TEXT_INSET, @@MENU_TEXT_WIDTH, @layer.h - 150, 0)
    mlc.in_section_cursor = TextRenderingConfig.new(@@MENU_TEXT_INSET , @@MENU_TEXT_WIDTH, @layer.h - 175, 0)
    mlc.in_subsection_cursor = BattleParticipantCursorTextRenderingConfig.new([AttackBattleMenuAction], 2 * @@MENU_TEXT_INSET + 4*@@MENU_TEXT_WIDTH, 0, @@MENU_TEXT_INSET, @@MENU_LINE_SPACING)
    mlc.in_option_section_cursor = BattleParticipantCursorTextRenderingConfig.new([UseBattleItemBattleMenuAction], 2 * @@MENU_TEXT_INSET + 4*@@MENU_TEXT_WIDTH, 0, @@MENU_TEXT_INSET, @@MENU_LINE_SPACING)
    mlc.main_cursor = TextRenderingConfig.new(@@MENU_TEXT_INSET , @@MENU_TEXT_WIDTH, @layer.h - 100, 0)
    mlc.layer_inset_on_screen = [@@LAYER_INSET,@@LAYER_INSET]
    mlc.details_inset_on_layer = [@@MENU_DETAILS_INSET_X, @@MENU_DETAILS_INSET_Y]
    mlc.options_inset_on_layer = [@@MENU_OPTIONS_INSET_X, @@MENU_OPTIONS_INSET_Y]

    mlc
  end
  def end_battle_menu_layer_config

    mlc = MenuLayerConfig.new
    mlc.main_menu_text = TextRenderingConfig.new(@@MENU_TEXT_INSET, @@MENU_TEXT_WIDTH, 50, 0)
    mlc.section_menu_text = TextRenderingConfig.new(@@MENU_TEXT_INSET, @@MENU_TEXT_WIDTH, 150, 0)
    mlc.in_section_cursor = TextRenderingConfig.new(@@MENU_TEXT_INSET , @@MENU_TEXT_WIDTH,200, 0)
    mlc.main_cursor = TextRenderingConfig.new(@@MENU_TEXT_INSET , @@MENU_TEXT_WIDTH,100, 0)
    mlc.layer_inset_on_screen = [@@LAYER_INSET,@@LAYER_INSET]
    mlc
  end

  def menu
    @menu
  end
  def draw()
    @layer.fill(:orange)
    if @battle.over?
      if @battle.player_alive?
        @end_menu.draw(end_battle_menu_layer_config, @game)
      else
        puts "you died ... game should be over... whatever"
        @end_menu.draw(end_battle_menu_layer_config, @game)
      end
    else
      @battle.monster.draw_to(@layer)
      rebuild_menu
      menu.draw(menu_layer_config, @cursor_helper.path, @cursor_helper.currently_selected)
    end

    @cursor_helper.draw_at_depth(@layer, menu_layer_config, @game, nil)
    @layer.blit(@screen, menu_layer_config.layer_inset_on_screen)
    @battle_hud.draw(menu_layer_config, @game, @battle) unless @battle.over?

  end

  def move_cursor_up(e)
    @cursor_helper.move_cursor_up(menu)
  end
  def move_cursor_down(e)
    @cursor_helper.move_cursor_down(menu)
  end

  def enter_current_cursor_location(e)
    @cursor_helper.activate(menu)
  end
  def current_selected_menu_entry_name
    @cursor_helper.current_selected_menu_entry_name(menu)
  end

  #TODO might have to rebuild menu here and in there check for the battle being over to deal with
  # having a different end of battle menu
  def current_menu_entries
    @cursor_helper.current_menu_entries(menu)
  end




end
