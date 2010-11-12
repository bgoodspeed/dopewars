
class BattleReadinessHelper
  attr_reader :points, :starting_points, :growth_rate

  def initialize(starting_points, growth_rate)
    @starting_points = starting_points
    @points = starting_points
    @growth_rate = growth_rate
    @points_needed_for_ready = GameSettings::READINESS_POINTS_NEEDED_TO_ACT
  end

  def add_readiness(points)
    @points += points * @growth_rate
  end

  def consume_readiness(pts)
    @points -= pts
  end

  def ready?
    @points >= @points_needed_for_ready
  end

  def ready_ratio
    @points.to_f/@points_needed_for_ready.to_f
  end
end
