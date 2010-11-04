# To change this template, choose Tools | Templates
# and open the template in the editor.

class Mission
  attr_reader :prerequisites, :objectives, :rewards, :description, :id_token
  def initialize(idtoken, desc, prerequisites, objectives, rewards)
    @id_token = idtoken
    @description = desc
    @prerequisites = prerequisites
    @objectives = objectives
    @rewards = rewards
  end

  def name
    @description
  end
  def achieved_of(milestones)
    milestones.select {|milestone| milestone.achieved? }
  end

  def fully_achieved?(milestones)
    achieved_of(milestones).size == milestones.size
  end
  def available?
    fully_achieved?(prerequisites)
  end

  def completed?
    fully_achieved?(objectives)
  end
end
