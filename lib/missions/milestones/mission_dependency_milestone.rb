# To change this template, choose Tools | Templates
# and open the template in the editor.

class MissionDependencyMilestone
  attr_accessor :game
  def initialize(game, dependent_mission_id_token)
    @game = game
    @dependent_mission_id_token = dependent_mission_id_token
  end

  def achieved?
    @game.mission_achieved?(@dependent_mission_id_token)
  end
end
