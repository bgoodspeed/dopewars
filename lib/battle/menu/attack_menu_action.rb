class AttackMenuAction < MenuAction
  def initialize(text, battle_layer, menu_helper)
    super(text, AttackAction.new)
    @battle_layer = battle_layer
    @menu_helper = menu_helper
  end

  def activate(party_member_index, game, action_idx, subsection_position=nil, option_position=nil)
    @menu_helper.set_active_subsection(action_idx)

    return false unless subsection_position
    battle = @battle_layer.battle

    hero = battle.player.party.members[party_member_index]
    target = battle.current_battle_participant(subsection_position)
    puts "I am going to attack #{target}"
    @action.perform(hero, target)
    msg = "attacked for #{hero.damage} damage"
#    msg += "hero #{hero} killed #{battle.monster}" if battle.monster.dead?
    game.add_notification(BattleScreenNotification.new("Attacked for #{hero.damage}"))
    false
  end

  def size
    @battle_layer.participants.size
  end

  def details
    false
  end
end
