class BattleScreenNotification < Notification
  def initialize(msg)
    super(msg,@@TICKS_TO_DISPLAY_NOTIFICATIONS, [@@NOTIFICATION_LAYER_INSET_X,@@NOTIFICATION_LAYER_INSET_Y/3 ])
  end
end
