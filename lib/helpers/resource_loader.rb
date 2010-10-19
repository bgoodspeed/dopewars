class MissingResourceError < Exception
  def initialize(msg)
    @msg = msg
  end
end
module ResourceLoader
  @@DEPTH = 24
  include Rubygame

  def font_path
    File.join(Dir.pwd, 'resources', 'fonts')
  end
  def load_font(name)
    filename = File.join(font_path, name)
    puts "font path: #{font_path} #{name}"
    raise MissingResourceError.new("font path: #{font_path} #{name}") unless File.exists?(filename)

    TTF.setup
    TTF.new filename, @@DEPTH
  end

  def surface_path
    File.join(Dir.pwd, 'resources', 'images')
  end

  def load_surface(name)
    filename = File.join(surface_path, name)

    raise MissingResourceError.new("font path: #{font_path} #{name}") unless File.exists?(filename)

    Surface.load(filename)
  end

end
