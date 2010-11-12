
class WorldScreenNotification < Notification
  def initialize(msg)
    super(msg,GameSettings::TICKS_TO_DISPLAY_NOTIFICATIONS, [GameSettings::NOTIFICATION_LAYER_INSET_X,GameSettings::NOTIFICATION_LAYER_INSET_Y ])
  end
end
