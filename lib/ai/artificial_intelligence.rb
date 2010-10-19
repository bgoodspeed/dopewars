
class ArtificialIntelligence
  extend Forwardable

  def_delegators :@battle_strategy, :take_battle_turn
  def_delegators :@follow_strategy, :update

  attr_accessor :follow_strategy, :battle_strategy
  def initialize(follow_strategy, battle_strategy)
    @follow_strategy = follow_strategy
    @battle_strategy = battle_strategy
  end

end
