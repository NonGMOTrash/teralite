extends Node2D

const LEVEL_TYPE = 1

func _ready() -> void:
	global.last_hub = get_tree().current_scene.get_name()
	global.write_save(global.save_name, global.get_save_data_dict())
	global.emit_signal("update_health")
	global.update_cursor()
	var player = $YSort.find_node("player")
	if player == null: 
		global.var_debug_msg(self, 0, player)
		return
	if global.player_hub_pos == null or global.player_hub_pos == Vector2.ZERO: return
	player.global_position = global.player_hub_pos
