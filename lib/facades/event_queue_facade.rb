# To change this template, choose Tools | Templates
# and open the template in the editor.

class EventQueueFacade < Rubygame::EventQueue

  def ignore_mouse_movement
    self.ignore = [Rubygame::Events::MouseMoved]
  end
end
