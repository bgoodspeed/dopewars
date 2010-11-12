class BattleScreenNotification < Notification
  def initialize(msg)
    super(msg,GameSettings::TICKS_TO_DISPLAY_NOTIFICATIONS, [GameSettings::NOTIFICATION_LAYER_INSET_X,GameSettings::NOTIFICATION_LAYER_INSET_Y/3 ])
  end
end
