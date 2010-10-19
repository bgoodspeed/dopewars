
module ScreenOffsetHelper
  def offset_from_screen(location, viewer_position, screen_extent)
    location - viewer_position + screen_extent
  end
end
