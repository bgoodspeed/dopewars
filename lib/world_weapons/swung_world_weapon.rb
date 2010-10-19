

class SwungWorldWeapon < WorldWeapon
  include ColorKeyHelper

  @@WEAPON_UP_OFFSET_X = -15
  @@WEAPON_UP_OFFSET_Y = -45
  @@WEAPON_DOWN_OFFSET_X = -15
  @@WEAPON_DOWN_OFFSET_Y = 20
  @@WEAPON_LEFT_OFFSET_X = -45
  @@WEAPON_LEFT_OFFSET_Y = -15
  @@WEAPON_RIGHT_OFFSET_X = 0
  @@WEAPON_RIGHT_OFFSET_Y = -10
  @@WEAPON_UP_ANGLE = 270
  @@WEAPON_DOWN_ANGLE = 120
  @@WEAPON_LEFT_ANGLE = -10
  @@WEAPON_RIGHT_ANGLE = 180
  @@WEAPON_ROTATION = 90

  def screen_config
    c = {}
    c[:up] = { :screen => [@@WEAPON_UP_OFFSET_X, @@WEAPON_UP_OFFSET_Y], :rotate => @@WEAPON_UP_ANGLE}
    c[:down] = { :screen => [@@WEAPON_DOWN_OFFSET_X, @@WEAPON_DOWN_OFFSET_Y], :rotate => @@WEAPON_DOWN_ANGLE}
    c[:left] = { :screen => [@@WEAPON_LEFT_OFFSET_X, @@WEAPON_LEFT_OFFSET_Y], :rotate => @@WEAPON_LEFT_ANGLE}
    c[:right] = { :screen => [@@WEAPON_RIGHT_OFFSET_X, @@WEAPON_RIGHT_OFFSET_Y], :rotate => @@WEAPON_RIGHT_ANGLE}
    c
  end

  def screen_offsets_for(facing)
    screen_config[facing][:screen]
  end

  def base_screen_offsets(screen)
    [screen.w/2, screen.h/2]
  end

  def effective_offsets(screen, facing)
    rv = base_screen_offsets(screen)
    so = screen_offsets_for(facing)
    rv[0] += so[0]
    rv[1] += so[1]
    rv
  end
  def starting_angle_for_facing(facing)
    screen_config[facing][:rotate]
  end
  def draw_weapon(screen)
    surf = @pallette['E'].surface
    surface = surf.rotozoom(consumption_ratio * @@WEAPON_ROTATION + starting_angle_for_facing(@facing), 1)
    set_colorkey_from_corner(surface)

    offs = effective_offsets(screen, @facing)
    surface.blit(screen,[ offs[0], offs[1], surface.w, surface.h])
  end

end