
class ItemMenuAction < MenuAction

  include Rubygame

  def initialize(text, battle_layer, menu_helper, game)
    super(text, ItemAction.new)
    @battle_layer = battle_layer
    @menu_helper = menu_helper
    @game = game
  end

  def activate(party_member_index, game, action_idx, subsection_position=nil, option_position=nil)
    @menu_helper.set_active_subsection(action_idx)

    return false unless subsection_position
    return true unless option_position

    battle = @battle_layer.battle
    hero = battle.player.party.members[party_member_index]
    item = battle.inventory_item_at(subsection_position)
    target = battle.current_battle_participant(option_position)
    puts "target is: #{option_position}->#{target}"
    @action.perform(hero, target, item)
    game.add_notification(BattleScreenNotification.new("Item used: #{item}"))
    false
  end

  def option_at(idx)
    @battle_layer.participants
  end

  def size
    @battle_layer.inventory.size
  end

  def info
    @game.inventory_info
  end

  def surface_for(posn)
    false
  end


  def details
    info_lines = info.collect {|item| item.to_info}
    s = Surface.new([@@STATUS_WIDTH, @@STATUS_HEIGHT])
    s.fill(:purple)
    @menu_helper.render_text_to(s, info_lines, TextRenderingConfig.new(0, 0, 0,@@MENU_LINE_SPACING))
    s
  end


end