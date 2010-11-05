# To change this template, choose Tools | Templates
# and open the template in the editor.

class MusicFacade < Rubygame::Music
  extend Forwardable
  def_delegators :@real, :play, :playing, :pause, :fade_out
  def initialize(real_music)
    @real = real_music
  end

  def self.load(filename)

    music = Rubygame::Music.load(filename)
    MusicFacade.new(music)
  end
end
