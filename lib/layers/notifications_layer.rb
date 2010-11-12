
class NotificationsLayer < AbstractLayer
  attr_reader :notifications
  def initialize(screen, game)
    super(screen, GameSettings::NOTIFICATION_LAYER_WIDTH, GameSettings::NOTIFICATION_LAYER_HEIGHT)
    @notifications = []
    @config = TextRenderingConfig.new(GameSettings::NOTIFICATION_TEXT_INSET, 0, GameSettings::NOTIFICATION_TEXT_INSET, GameSettings::NOTIFICATION_LINE_SPACING )
  end

  def add_notification(notification)
    @notifications << notification
    @active = true
  end

  def config_for(idx)
    TextRenderingConfig.new(GameSettings::NOTIFICATION_TEXT_INSET, 0, GameSettings::NOTIFICATION_TEXT_INSET, GameSettings::NOTIFICATION_LINE_SPACING * idx)
  end

  def draw
    @layer.fill(:black)

    @notifications.delete_if do |notif|
      notif.dead?
    end

    msgs = @notifications.collect {|n| n.message}
    @text_rendering_helper.render_lines_to_layer(msgs, @config)
    @notifications.each {|n| n.displayed}

    unless @notifications.empty?
      @layer.blit(@screen, @notifications[0].location)
    end

    @active = false if @notifications.empty?
  end
end