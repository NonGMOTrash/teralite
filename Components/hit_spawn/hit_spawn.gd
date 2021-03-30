extends Node

export var spawn_entity = ""
export(int, 100) var percent_chance = 100

export var types_list = ["hurt"]
export var use_whitelist = true

var stats

func _on_hit_spawn_tree_entered() -> void:
	get_parent().components["hit_spawn"] = self

func _ready() -> void:
	push_error("there's a hit spawn!!!! replace with a spawner")
	
	percent_chance = clamp(percent_chance, 0, 100)
	
	if spawn_entity == "":
		push_warning("spawn_entity was not set")
		queue_free()
		return
	
	stats = get_parent().components["stats"]
	
	if stats == null:
		global.var_debug_msg(self, 1, stats)
		queue_free()
		return
	
	stats.connect("health_changed", self, "spawn")

func spawn(type):
	if use_whitelist == false:
		if types_list.has(type): return
	else:
		if not types_list.has(type): return
	
	if rand_range(1, 100) <= percent_chance: #spawn entity
		
		var new_entity = global.aquire(spawn_entity)
		
		new_entity.global_position = get_parent().global_position
		
		get_parent().get_parent().call_deferred("add_child", new_entity)

