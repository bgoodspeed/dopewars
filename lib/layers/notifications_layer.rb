
class NotificationsLayer < AbstractLayer
  def initialize(screen, game)
    super(screen, @@NOTIFICATION_LAYER_WIDTH, @@NOTIFICATION_LAYER_HEIGHT)
    @notifications = []
    @config = TextRenderingConfig.new(@@NOTIFICATION_TEXT_INSET, 0, @@NOTIFICATION_TEXT_INSET, @@NOTIFICATION_LINE_SPACING )
  end

  def add_notification(notification)
    @notifications << notification
    @active = true
  end

  def config_for(idx)
    TextRenderingConfig.new(@@NOTIFICATION_TEXT_INSET, 0, @@NOTIFICATION_TEXT_INSET, @@NOTIFICATION_LINE_SPACING * idx)
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