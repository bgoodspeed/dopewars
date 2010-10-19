
class ArtificialIntelligence
  extend Forwardable

  def_delegators :@battle_strategy, :take_battle_turn

  def initialize(follow_strategy, battle_strategy)
    @follow_strategy = follow_strategy
    @battle_strategy = battle_strategy
  end

  def update(event)
    @follow_strategy.update(event)
  end
end
