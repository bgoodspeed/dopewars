
class WorldScreenNotification < Notification
  def initialize(msg)
    super(msg,@@TICKS_TO_DISPLAY_NOTIFICATIONS, [@@NOTIFICATION_LAYER_INSET_X,@@NOTIFICATION_LAYER_INSET_Y ])
  end
end
