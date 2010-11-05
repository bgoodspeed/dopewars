
class AnimatedSpriteHelper
  include Rubygame
  attr_reader :image, :rect, :px, :py
  include ColorKeyHelper
  include ResourceLoader
  
  def initialize(filename, position, surface_factory=SurfaceFactory.new)
    @all_char_postures = load_surface(filename)

    set_colorkey_from_corner(@all_char_postures)
    @all_char_postures.alpha = 255

    @px = position.position.x
    @py = position.position.y #XXX this might be a bug to use these, they should come from the coord helper?
    @avatar_x_dim = position.dimension.x
    @avatar_y_dim = position.dimension.y


    @image = surface_factory.make_surface([@avatar_x_dim, @avatar_y_dim])
    @image.fill(@all_char_postures.colorkey)
    @image.colorkey = @all_char_postures.colorkey
    @image.alpha = 255
    @all_char_postures.blit(@image, [0,0], Rect.new(0,0,@avatar_x_dim,@avatar_y_dim))

    @rect = @image.make_rect
    @rect.center = [px, py]

    set_frame(0)
  end


  def set_frame_from(newkey)
    if newkey == :down
      set_frame(0)
    elsif newkey == :left
      set_frame(@avatar_y_dim)
    elsif newkey == :right
      set_frame(2 * @avatar_y_dim)
    elsif newkey == :up
      set_frame(3 * @avatar_y_dim)
    end

  end

  def set_frame(last_dir=0)
    @last_direction_offset = last_dir
  end

  def replace_avatar(animation_frame)
    @image.fill(@all_char_postures.colorkey)
    @all_char_postures.blit(@image, [0,0], Rect.new(animation_frame * @avatar_x_dim, @last_direction_offset,@avatar_x_dim, @avatar_y_dim))
  end


end


