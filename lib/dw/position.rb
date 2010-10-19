# To change this template, choose Tools | Templates
# and open the template in the editor.

class Position
  def initialize(px,py)
    @px, @py = px, py # Current Position
    @vx, @vy = 0, 0 # Current Velocity
    @ax, @ay = 0, 0 # Current Acceleration

    @max_speed = 400.0 # Max speed on an axis
    @accel = 1200.0 # Max Acceleration on an axis
    @slowdown = 800.0 # Deceleration when not accelerating

  end


  def update_all(x,y, dt)
    update_accel(x,y)
    update_vel( dt )
    update_pos( dt )
  end

  # Update the acceleration based on what keys are pressed.
  def update_accel(x,y)
    # Scale to the acceleration rate. This is a bit unrealistic, since
    # it doesn't consider magnitude of x and y combined (diagonal).
    x *= @accel
    y *= @accel

    @ax, @ay = x, y
  end


  # Update the velocity based on the acceleration and the time since
  # last update.
  def update_vel( dt )
    @vx = update_vel_axis( @vx, @ax, dt )
    @vy = update_vel_axis( @vy, @ay, dt )
  end


  # Calculate the velocity for one axis.
  # v = current velocity on that axis (e.g. @vx)
  # a = current acceleration on that axis (e.g. @ax)
  #
  # Returns what the new velocity (@vx) should be.
  #
  def update_vel_axis( v, a, dt )

    # Apply slowdown if not accelerating.
    if a == 0
      if v > 0
        v -= @slowdown * dt
        v = 0 if v < 0
      elsif v < 0
        v += @slowdown * dt
        v = 0 if v > 0
      end
    end

    # Apply acceleration
    v += a * dt

    # Clamp speed so it doesn't go too fast.
    v = @max_speed if v > @max_speed
    v = -@max_speed if v < -@max_speed

    return v
  end


  # Update the position based on the velocity and the time since last
  # update.
  def update_pos( dt )
    @px += @vx * dt
    @py += @vy * dt
  end
  def x
    @px
  end
  def y
    @py
  end
end
