
class BattleStrategy
  def initialize(tactics)
    @tactics = tactics
  end

  def take_battle_turn(actor, battle)
    puts "take #{actor}s battle turn in #{battle}"

    battle.participants.each {|foe| #TODO this should be each battle participant, including self
      @tactics.each {|tactic|
        if tactic.matches?(actor, foe)
          tactic.perform_on(actor, foe)
        end
      }
    }

    actor.consume_readiness(@@NOOP_ACTION_COST)
  end
end
