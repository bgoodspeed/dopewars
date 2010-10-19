
class AnimatedSpriteHelper
  include Rubygame
  attr_reader :image, :rect, :px, :py
  include ColorKeyHelper
  include ResourceLoader
  
  def initialize(filename, px, py, avatar_x_dim, avatar_y_dim)
    @all_char_postures = load_surface(filename)

    set_colorkey_from_corner(@all_char_postures)
    @all_char_postures.alpha = 255

    @px = px
    @py = py #XXX this might be a bug to use these, they should come from the coord helper?
    @avatar_x_dim = avatar_x_dim
    @avatar_y_dim = avatar_y_dim


    @image = Surface.new([@avatar_x_dim,@avatar_y_dim])
    @image.fill(@all_char_postures.colorkey)
    @image.colorkey = @all_char_postures.colorkey
    @image.alpha = 255
    @all_char_postures.blit(@image, [0,0], Rect.new(0,0,@avatar_x_dim,@avatar_y_dim))

    @rect = @image.make_rect
    @rect.center = [px, py]

    set_frame(0)
  end


  def set_frame(last_dir=0)
    @last_direction_offset = last_dir
  end

  def replace_avatar(animation_frame)
    @image.fill(@all_char_postures.colorkey)
    @all_char_postures.blit(@image, [0,0], Rect.new(animation_frame * @avatar_x_dim, @last_direction_offset,@avatar_x_dim, @avatar_y_dim))
  end


end


