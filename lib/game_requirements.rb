# To change this template, choose Tools | Templates
# and open the template in the editor.

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

require 'lib/menu/task_menu'


require 'lib/menu/selectors/selections'
require 'lib/menu/selectors/static_menu_selector'
require 'lib/menu/selectors/equipment_slot_menu_selector'
require 'lib/menu/selectors/filtered_inventory_menu_selector'
require 'lib/menu/selectors/inventory_filter_menu_selector'
require 'lib/menu/selectors/party_menu_selector'
require 'lib/menu/selectors/save_slot_menu_selector'
require 'lib/menu/selectors/stat_line_menu_selector'

require 'lib/menu/actions/selector_dependency_helper'
require 'lib/menu/actions/equip_item_in_member_slot_menu_action'
require 'lib/menu/actions/level_up_stat_menu_action'
require 'lib/menu/actions/save_game_menu_action'
require 'lib/menu/actions/load_game_menu_action'
require 'lib/menu/actions/stat_line_info_menu_action'
require 'lib/menu/actions/use_item_menu_action'

require 'lib/menu/cursor_helper'
require 'lib/menu/menu_layer_config'
#TODO delete this
require 'lib/menu/noop_action'
require 'lib/menu/menu_helper'
require 'lib/menu/menu_action'
require 'lib/menu/menu_section'
require 'lib/menu/menu_sections'
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

#to here

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
