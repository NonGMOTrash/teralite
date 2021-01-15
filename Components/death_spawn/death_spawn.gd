extends Node

export var spawn_entity = ""
export(int, 100) var percent_chance = 100
export(bool) var inheiriet_properties = true
export var properties = {
	"Position?": true,
	"Faction?": false,
	"Color?": false,
	"Flipping?": true
}

func _on_death_spawn_tree_entered() -> void:
	get_parent().components["death_spawn"] = self

func _ready() -> void:
	percent_chance = clamp(percent_chance, 0, 100)
	
	if get_parent() == null || spawn_entity == "":
		queue_free()
		return
	
	spawn_entity = spawn_entity.to_lower()
	
	get_parent().connect("tree_exiting", self, "spawn")

func spawn():
	if spawn_entity == "": return
	
	if rand_range(1, 100) <= percent_chance: #spawn entity
		
		var spawn = global.aquire(spawn_entity)
		
		var sprite = get_parent().components["entity_sprite"]
		if sprite == null: sprite = get_parent().find_node("Sprite")
		
		# property inheiritence
		if properties["Position?"] == true:
			spawn.global_position = get_parent().global_position
		
		if properties["Faction?"] == true:
			if spawn is Entity:
				spawn.faction = get_parent().faction
		
		if properties["Color?"] == true:
			var spawn_sprite
			
			if spawn is Effect:
				spawn_sprite = spawn
			else:
				spawn.find_node("entity_sprite")
				if spawn_sprite == null: spawn_sprite = spawn.find_node("Sprite")
				elif spawn_sprite == null: spawn_sprite = spawn.find_Node("sprite")
			
			if spawn_sprite == null:
				spawn.modulate = sprite.self_modulate
			else:
				spawn_sprite.modulate = sprite.self_modulate
			
		
		if properties["Flipping?"] == true:
			var spawn_sprite = spawn.find_node("entity_sprite")
			if spawn_sprite == null: spawn_sprite = spawn.find_node("Sprite")
			elif spawn_sprite == null: spawn_sprite = spawn.find_Node("sprite")
			if spawn_sprite == null:
				push_warning("spawn_sprite == null")
				return
			
			spawn_sprite.flip_h = sprite.flip_h
			spawn_sprite.flip_v = sprite.flip_v
		
		get_parent().get_parent().call_deferred("add_child", spawn)
