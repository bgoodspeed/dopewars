
class Notification
  attr_reader :message, :time_to_live, :location
  def initialize(msg, ttl, location)
    @message = msg
    @time_to_live = ttl
    @location = location
  end

  def displayed
    @time_to_live -= 1
  end

  def dead?
    @time_to_live <= 0
  end
end
