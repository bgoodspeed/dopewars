class MissingResourceError < RuntimeError
end

module ResourceLoader
  @@FONT_DEPTH = 24

  def resource_path(elem)
    File.join(Dir.pwd, 'resources', elem)
  end

  def font_path
    resource_path('fonts')
  end
  def load_font(name)
    FontFacade.new(check_file(font_path, name), @@FONT_DEPTH)
  end

  def surface_path
    resource_path('images')
  end

  def load_surface(name)
    SurfaceFacade.load(check_file(surface_path, name))
  end

  def music_path
    resource_path('music')
  end

  def load_music(name)
    MusicFacade.load(check_file(music_path, name))
  end

  def sound_path
    resource_path('sounds')
  end

  def check_file(path, name)
    filename = File.join(path, name)
    raise MissingResourceError.new(filename) unless File.exists?(filename)
    filename
  end

  def load_sound(name)
    SoundFacade.load(check_file(sound_path, name))
  end

  def map_path
    resource_path('worlds')
  end


  def load_mapfile(name)
    filename = File.join(map_path, name)
    IO.readlines(filename)
  end
end
