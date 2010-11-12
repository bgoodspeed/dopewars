
class AnimationHelper

  def current_frame
    @animation_frame
  end

  def initialize(key_holder, animation_frames=GameSettings::ANIMATION_FRAMES)
    @key_holder = key_holder
    @animation_counter = 0
    @animation_frame = 0
    @animation_frames = animation_frames
  end
  def update_animation(dt)
    @animation_counter += dt
    if @animation_counter > GameSettings::FRAME_SWITCH_THRESHOLD
      @animation_counter = 0
      unless @key_holder.empty?
        @animation_frame = (@animation_frame + 1) % @animation_frames
        yield @animation_frame
      end
    end

  end

end
