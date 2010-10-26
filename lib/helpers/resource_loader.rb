class MissingResourceError < RuntimeError
end

module ResourceLoader
  @@DEPTH = 24
  include Rubygame

  def font_path
    File.join(Dir.pwd, 'resources', 'fonts')
  end
  def load_font(name)
    filename = File.join(font_path, name)
    puts "font"
    raise MissingResourceError.new unless File.exists?(filename)

    TTF.setup
    TTF.new filename, @@DEPTH
  end

  def surface_path
    File.join(Dir.pwd, 'resources', 'images')
  end

  def load_surface(name)
    filename = File.join(surface_path, name)
    raise MissingResourceError.new unless File.exists?(filename)

    Rubygame::Surface.load(filename)
  end


  def sound_path
    File.join(Dir.pwd, 'resources', 'sounds')
  end
  
  def load_music(name)
    filename = File.join(sound_path, name)

    raise MissingResourceError.new(filename) unless File.exists?(filename)

    Music.load(filename)
  end

  def load_sound(name)
    filename = File.join(sound_path, name)

    raise MissingResourceError.new(filename) unless File.exists?(filename)

    Sound.load(filename)
  end

  def map_path
    File.join(Dir.pwd, 'resources', 'worlds')
  end


  def load_mapfile(name)
    filename = File.join(map_path, name)
    IO.readlines(filename)
  end
end
