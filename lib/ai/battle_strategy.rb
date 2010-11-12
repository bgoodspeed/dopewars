
class TacticalMatch
  attr_reader :tactic, :target, :actor
  def initialize(tactic, target, actor)
    @tactic, @target, @actor = tactic, target, actor
  end
  def matches?
    true
  end

  def perform
    @tactic.perform_on(@actor, @target)
  end
end

class NoTacticalMatch
  def matches?
    false
  end
end

class BattleStrategy
  def initialize(tactics)
    @tactics = tactics
  end

  def first_matching_tactic(foes, actor)
    @tactics.each {|tactic|
      foes.each {|target|
        return TacticalMatch.new(tactic, target, actor) if tactic.matches?(actor, target)
      }
    }
    NoTacticalMatch.new
  end

  def take_battle_turn(actor, battle)
    tactic = first_matching_tactic(battle.participants, actor)
    if tactic.matches?
      tactic.perform
    else
      actor.consume_readiness(GameSettings::NOOP_ACTION_COST)
    end
  end
end
