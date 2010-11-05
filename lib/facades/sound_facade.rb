# To change this template, choose Tools | Templates
# and open the template in the editor.

class SoundFacade

  extend Forwardable

  def_delegators :@real, :play

  def initialize(real_sound)
    @real = real_sound
  end

  def self.load(filename)
    sound = Rubygame::Sound.load(filename)
    SoundFacade.new(sound)
  end
end
