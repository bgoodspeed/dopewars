

class MonsterCoordinateHelper < CoordinateHelper
  def candidate_npcs(who=nil)
    r = super()
    cands = (r - [who]) # + [who.player]

    cands
  end
  def handle_collision(cols)
    #NOOP
  end
end
