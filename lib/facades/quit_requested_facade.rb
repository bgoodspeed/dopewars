# To change this template, choose Tools | Templates
# and open the template in the editor.

class QuitRequestedFacade < Rubygame::Events::QuitRequested

  def self.quit_request_type
    Rubygame::Events::QuitRequested
  end
end
