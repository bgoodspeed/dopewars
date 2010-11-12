
class GameLayers
  extend Forwardable
  def_delegator :@menu_layer, :move_cursor_up, :menu_move_cursor_up
  def_delegator :@menu_layer, :move_cursor_down, :menu_move_cursor_down
  def_delegator :@menu_layer, :cancel_action, :menu_cancel_action
  def_delegators :@menu_layer, :current_selected_menu_entry_name, :current_menu_entries
  def_delegator :@battle_layer, :move_cursor_up, :battle_move_cursor_up
  def_delegator :@battle_layer, :move_cursor_down, :battle_move_cursor_down
  def_delegator :@battle_layer, :cancel_action, :battle_cancel_action
  def_delegators :@notifications_layer, :add_notification, :notifications
  def_delegators :@battle_layer, :current_battle_participant_offset



  attr_accessor :dialog_layer, :menu_layer, :battle_layer, :notifications_layer
  def initialize(dialog_layer=nil, menu_layer=nil, battle_layer=nil, notif_layer=nil)
    @dialog_layer = dialog_layer
    @menu_layer = menu_layer
    @battle_layer = battle_layer
    @notifications_layer = notif_layer
  end

  def draw_game_layers_if_active
    if @dialog_layer.active?
      @dialog_layer.draw
    end
    if @menu_layer.active?
      @menu_layer.draw
    end
    if @battle_layer.active?
      @battle_layer.draw
    end
    if @notifications_layer.active?
      @notifications_layer.draw
    end
  end

  def reset_menu_positions
    @menu_layer.reset_indices
  end
end

