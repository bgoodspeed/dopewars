#!/bin/env ruby

# One way of making an object start and stop moving gradually:
# make user input affect acceleration, not velocity.

require 'rubygems'

require 'rubygame'
require 'json'
require 'forwardable'



@@SCREEN_X = 640
@@SCREEN_Y = 480
@@BGX = 1280
@@BGY = 960
@@MENU_LAYER_INSET = 25
@@MENU_TEXT_INSET = 10
@@NOTIFICATION_TEXT_INSET = 10
@@MENU_LINE_SPACING = 25
@@NOTIFICATION_LINE_SPACING = 25
@@MENU_TEXT_WIDTH = 100
@@LAYER_INSET = 25
@@TEXT_INSET = 10
@@HERO_START_BATTLE_PTS = 1000
@@HERO_BATTLE_PTS_RATE = 1.1
@@MONSTER_START_BATTLE_PTS = 800
@@MONSTER_BATTLE_PTS_RATE = 1.0
@@READINESS_POINTS_PER_SECOND = 1000
@@READINESS_POINTS_NEEDED_TO_ACT = 3000
@@DEFAULT_ACTION_COST = 2500
@@ATTACK_ACTION_COST = 2000
@@ITEM_ACTION_COST = 1500
@@NOOP_ACTION_COST = 1000

@@OPEN_TREASURE = 'O'
@@MONSTER_X = 32
@@MONSTER_Y = 32
@@NOTIFICATION_LAYER_WIDTH = @@SCREEN_X/3
@@NOTIFICATION_LAYER_HEIGHT = @@SCREEN_Y/3
@@NOTIFICATION_LAYER_INSET_X = 2 * @@SCREEN_X/3
@@NOTIFICATION_LAYER_INSET_Y = 2 * @@SCREEN_Y/3
@@TICKS_TO_DISPLAY_NOTIFICATIONS = 125
@@GAME_TITLE = "splatwars"

@@STATUS_WIDTH = 100
@@STATUS_HEIGHT = 300
@@MENU_DETAILS_INSET_X = 300
@@MENU_DETAILS_INSET_Y = 25
@@MENU_OPTIONS_INSET_X = 400
@@MENU_OPTIONS_INSET_Y = 25


@@BATTLE_INVENTORY_XC = 400
@@BATTLE_INVENTORY_XF = 0
@@BATTLE_INVENTORY_YC = 25
@@BATTLE_INVENTORY_YF = 25




# untested \/
require 'lib/helpers/resource_loader'
require 'lib/helpers/color_key_helper'
require 'lib/helpers/json_helper'
require 'lib/helpers/screen_offset_helper'
require 'lib/helpers/animation_helper'
require 'lib/helpers/animated_sprite_helper'

require 'lib/tile_system/json_surface'
require 'lib/tile_system/json_loadable_surface'
require 'lib/tile_system/coordinate_helper'

require 'lib/input/key_holder'
require 'lib/input/event_helper'
require 'lib/input/event_manager'

require 'lib/layers/hud'
require 'lib/domain/inventory'
require 'lib/domain/hero'
require 'lib/domain/world_state'
require 'lib/domain/universe'
require 'lib/domain/party'
require 'lib/domain/player'

require 'lib/npcs/always_down_monster_key_holder'
require 'lib/npcs/monster_coordinate_helper'
require 'lib/npcs/monster'
require 'lib/npcs/talking_n_p_c'

require 'lib/traits/character_attributes'
require 'lib/traits/character_state'
require 'lib/traits/character_attribution'

require 'lib/items/item_attributes'
require 'lib/items/item_state'
require 'lib/items/game_item'
require 'lib/items/equipment/equippable_game_item'
require 'lib/items/equipment/equipment_holder'


require 'lib/factories/game_item_factory'
require 'lib/factories/world_state_factory'
require 'lib/factories/game_internals_factory'
require 'lib/factories/topo_map_factory'

require 'lib/tile_system/topo_map'
require 'lib/tile_system/interpreted_map'
require 'lib/tile_system/coordinate_helper'
require 'lib/tile_system/interaction_helper'
require 'lib/tile_system/interaction_policy'
require 'lib/tile_system/tile_coordinate_set'

require 'lib/interactables/warp_point'
require 'lib/interactables/treasure'
require 'lib/interactables/open_treasure'

require 'lib/sound/background_music'
require 'lib/sound/sound_effect'
require 'lib/sound/sound_effect_set'

require 'lib/notifications/notification'
require 'lib/notifications/world_screen_notification'
require 'lib/notifications/battle_screen_notification'

require 'lib/menu/noop_action'
require 'lib/menu/menu_action'
require 'lib/menu/menu_section'
require 'lib/menu/abstract_actor_menu_action'
require 'lib/menu/hero_menu_section'
require 'lib/menu/inventory_display_action'
require 'lib/menu/key_inventory_display_action'
require 'lib/menu/level_up_action'
require 'lib/menu/sort_inventory_action'
require 'lib/menu/status_display_action'
require 'lib/menu/update_equipment_action'
require 'lib/menu/menu_helper'
require 'lib/menu/menu_layer_config'
require 'lib/menu/save_load_menu_action'
require 'lib/menu/save_menu_action'
require 'lib/menu/load_menu_action'


require 'lib/text/text_rendering_config'
require 'lib/text/text_rendering_helper'

require 'lib/world_weapons/world_weapon_interaction_helper'
require 'lib/world_weapons/world_weapon'
require 'lib/world_weapons/swung_world_weapon'
require 'lib/world_weapons/shot_world_weapon'
require 'lib/world_weapons/world_weapon_helper'

require 'lib/processes/attack_action'
require 'lib/processes/item_action'
require 'lib/processes/reloader_helper'

require 'lib/ai/action_invoker'
require 'lib/ai/artificial_intelligence'
require 'lib/ai/static_path_follower'
require 'lib/ai/repeating_path_follower'
require 'lib/ai/condition_matcher'
require 'lib/ai/target_matcher'
require 'lib/ai/battle_tactic'
require 'lib/ai/battle_strategy'

require 'lib/npcs/monster'

require 'lib/battle/battle'
require 'lib/battle/damage_calculation_helper'
require 'lib/battle/battle_readiness_helper'
require 'lib/battle/battle_victory_helper'
require 'lib/battle/battle_hud'
require 'lib/battle/battle_menu_helper'
require 'lib/battle/battle_participant_cursor_text_rendering_config'
require 'lib/battle/menu/attack_menu_action'
require 'lib/battle/menu/end_battle_menu_action'
require 'lib/battle/menu/item_menu_action'

require 'lib/palettes/i_s_b_p_entry'
require 'lib/palettes/s_b_p_entry'
require 'lib/palettes/c_i_s_b_p_entry'
require 'lib/palettes/i_s_b_p_result'
require 'lib/palettes/s_b_p_result'
require 'lib/palettes/pallette'
require 'lib/palettes/surface_backed_pallette'
require 'lib/palettes/interactable_surface_backed_pallette'
require 'lib/palettes/composite_interactable_surface_backed_pallette'

require 'lib/layers/game_layers'
require 'lib/layers/abstract_layer'
require 'lib/layers/battle_layer'
require 'lib/layers/dialog_layer'
require 'lib/layers/menu_layer'
require 'lib/layers/notifications_layer'

require 'lib/domain/game'

g = Game.new

puts "maybe stick the intro screen here"
#require 'drx'
#g.universe.menu_layer.see

g.go

Rubygame.quit()