extends Node

export(PackedScene) var thing
export(bool) var spawn_on_free = true
export(bool) var spawn_on_hurt = false
export(bool) var spawn_on_block = false
export(bool) var spawn_on_heal = false
export(bool) var rotate_away_from_me = false

export var use_modulate = false
export(Color) var modulate

export(Texture) var effect_texture
export(int) var effect_hframes = 1
export(int) var effect_vframes = 1

var stats
var trigger_pos

func _on_spawner_tree_entered():
	get_parent().components["spawner"] = self

func _ready() -> void:
	if (
		spawn_on_free == false and
		spawn_on_hurt == false and
		spawn_on_block == false and
		spawn_on_heal == false
	):
		push_error("spawner has no spawn conditions")
		queue_free()
		return
	
#	if thing == null:
#		if get_child_count() == 0:
#			push_error("spawner has no spawn")
#		elif get_child_count() > 1:
#			push_warning("spawner has multiple children, but can only use the first child")
#		thing = get_child(0)
	
	if spawn_on_free == true:
		get_parent().connect("tree_exiting", self, "spawn")
	
	stats = get_parent().components["stats"]
	
	if stats == null:
		push_warning("spawner could not find stats")
		if spawn_on_free == false:
			queue_free()
		return
	
	stats.connect("health_changed", self, "on_health_changed")
	
	if rotate_away_from_me == true:
		var hurtbox = get_parent().components["hurtbox"]
		if hurtbox != null:
			hurtbox.connect("got_hit", self, "hurtbox_got_hit")

func on_health_changed(type):
	match type:
		"hurt": if spawn_on_hurt == true: spawn()
		"block": if spawn_on_block == true: spawn()
		"heal": if spawn_on_heal == true: spawn()

func hurtbox_got_hit(by_area, type):
	var src_entity = by_area.get_parent()
	#if src_entity is Attack:
	#	src_entity = src_entity.SOURCE
	
	trigger_pos = src_entity.global_position
	prints(get_parent().get_name(), src_entity.get_name())

func spawn():
	if thing == null:
		push_error(get_parent().get_name()+"'s spawners's 'thing' was not set")
		queue_free()
		return
	
	if global.nodes["ysort"] == null:
		push_error("global.nodes['ysort'] == null")
		return
	
	var new_thing: Node2D = thing.instance()
	
	new_thing.global_position = get_parent().global_position
	
	if use_modulate == true:
		new_thing.modulate = modulate
	
	if rotate_away_from_me == true:
		if trigger_pos != null:
			new_thing.rotation_degrees = rad2deg(
					get_parent().global_position.direction_to(trigger_pos).angle())
			
		else:
			push_warning("spawner could not do rotate_away_from_me because last_hitbox_pos == null")
	
	if new_thing is Effect:
		var sprite = new_thing.get_node(new_thing.sprite)
		
		if sprite == null:
			push_error("effect sprite could not be found")
			return
		
		if effect_texture != null:
			sprite.texture = effect_texture
	
		sprite.hframes = effect_hframes
		sprite.vframes = effect_vframes
		
		var my_sprite = get_parent().components["entity_sprite"]
		if my_sprite != null:
			sprite.flip_h = my_sprite.flip_h
			sprite.flip_v = my_sprite.flip_v
	
	global.nodes["ysort"].call_deferred("add_child", new_thing)
