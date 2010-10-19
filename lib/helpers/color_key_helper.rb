
module ColorKeyHelper

  def set_colorkey_from_corner(s)
    s.colorkey = s.get_at(0,0)
  end
end