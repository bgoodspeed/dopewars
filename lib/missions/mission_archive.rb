# To change this template, choose Tools | Templates
# and open the template in the editor.

class MissionArchive
  
  def initialize(game)
    @game = game
    @achieved_mission_tokens = []
  end

  def mark_completed(mission)
    @achieved_mission_tokens << mission.id_token
  end

  def mission_achieved?(mission_id_token)
    @achieved_mission_tokens.include?(mission_id_token)
  end

  def missions
    all_missions.select {|m| m.available? }
  end

  #XXX anything of type Milestone must be able to generate events
  # so that we can check for new mission availability
  # per dialog/city visitation/battle/stat upgrade seems reasonable times to
  # fire the recalculation of the available missions
  # on the other hand, checking every tick or every step taken implies
  # scheduling & polling rather than event driven
  # or the events have to run really fast?
  def all_missions(game=@game)
    [
      Mission.new(:ten_upgrades, "Upgrade yourself",
            [],
            [CharacterProgressMilestone.new(game, 10)],
            [MoneyReward.new(game, 50)]),
      Mission.new(:first_friend, "Find your first friend",
            [],
            [PartySizeMilestone.new(game, 2)],
            [MoneyReward.new(game, 50)]),
      Mission.new(:second_friend, "Find your second friend", 
            [MissionDependencyMilestone.new(game, :first_friend)],
            [PartySizeMilestone.new(game, 3)],
            [MoneyReward.new(game, 100), ItemReward.new(game, GameItemFactory.potion)]),

    ]
  end
end
