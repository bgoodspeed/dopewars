# To change this template, choose Tools | Templates
# and open the template in the editor.

class MissionInfoMenuAction < MenuAction
  def initialize(game)
    super(game,"Missions", [
      MissionMenuSelector.new(game)
    ])
    
  end
end
