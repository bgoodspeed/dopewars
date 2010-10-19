
class BackgroundMusic
  def initialize(filename)
    @filename = filename
    @music = Music.load(@filename)
  end

  def play_pause
    if @music.playing?
      @music.pause
    else
      @music.play
    end
  end
  def fade_out_bg_music
    @music.fade_out(2)
  end
  def fade_in_bg_music
    @music.play({:fade_in => 2})
  end
end

