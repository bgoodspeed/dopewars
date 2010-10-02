
# A class representing the player's ship moving in "space".
class Ship
  include Rubygame
include Rubygame::Events
include Rubygame::EventActions
include Rubygame::EventTriggers


  include Sprites::Sprite
  include EventHandler::HasEventHandler
  def initialize( px, py )
    @position = Position.new(px,py)

    @keys = [] # Keys being pressed


    # The ship's appearance. A white square for demonstration.
    @image = Surface.new([20,20])
    @image.fill(:white)
    @rect = @image.make_rect


    # Create event hooks in the easiest way.
    make_magic_hooks(

      # Send keyboard events to #key_pressed() or #key_released().
      KeyPressed => :key_pressed,
      KeyReleased => :key_released,

      # Send ClockTicked events to #update()
      ClockTicked => :update

    )
  end

  def position_x
    @position.x
  end
  def position_y
    @position.y
  end

  private


  # Add it to the list of keys being pressed.
  def key_pressed( event )
    @keys += [event.key]
  end


  # Remove it from the list of keys being pressed.
  def key_released( event )
    @keys -= [event.key]
  end


  # Update the ship state. Called once per frame.
  def update( event )
    dt = event.seconds # Time since last update

    x,y = 0, 0
    x -= 1 if @keys.include?( :left )
    x += 1 if @keys.include?( :right )
    y -= 1 if @keys.include?( :up ) # up is down in screen coordinates
    y += 1 if @keys.include?( :down )

    @position.update_all(x,y, dt)
    @rect.center = [@position.x, @position.y]
  end


end

