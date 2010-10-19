class SoundEffectSet
  include Rubygame
  include ResourceLoader

  def initialize(filenames)
    @effects = {}
    filenames.each do |filename|
      @effects[filename] = load_sound(filename)
    end
  end

  def mapping
    pal = {}
    pal[SoundEffect::TREASURE] = "treasure-open.ogg"
    pal[SoundEffect::WEAPON] = "laser.ogg"
    pal[SoundEffect::WARP] = "warp.ogg"
    pal[SoundEffect::BATTLE_START] = "battle-start.ogg"
    pal
  end

  def play_sound_effect(which)
    @effects[mapping[which]].play
  end
end