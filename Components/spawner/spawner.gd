extends Node

enum ROTATIONS {
	KEEP = -1,
	TOWARD_HITBOX,
	TOWARD_CURSOR
}

export(bool) var standby_mode = false # requires 'thing' to be set

export(PackedScene) var thing
export(bool) var spawn_on_free = true
export(bool) var spawn_on_hurt = false
export(bool) var spawn_on_block = false
export(bool) var spawn_on_heal = false
export(ROTATIONS) var rotation_mode = ROTATIONS.KEEP

export var use_modulate = false
export(Color) var modulate
export(int) var random_position_offset = 0

export(Texture) var effect_texture
export(int) var effect_hframes = 1
export(int) var effect_vframes = 1
export(bool) var effect_inherit_flipping = true

export(bool) var particle_one_shot = true
export(int, 1) var particle_amount = 5
export(float, 0, 64) var particle_speed_scale = 1.0

export(bool) var entity_inherit_velocity := false

var stats
var trigger_pos
var entity: Entity

func _on_spawner_tree_entered():
	# finds owner entity
	var test = get_parent()
	while not test is Entity:
		test = test.get_parent()
		if test is YSort:
			push_error("spawner could not find it's owner entity")
			break
	entity = test
	
	entity.components["spawner"] = self

func _ready() -> void:
	if (
		spawn_on_free == false and
		spawn_on_hurt == false and
		spawn_on_block == false and
		spawn_on_heal == false and
		standby_mode == false
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
		entity.connect("tree_exiting", self, "spawn")
	
	stats = entity.components["stats"]
	
	if stats == null:
		push_warning("spawner could not find stats")
		if spawn_on_free == false:
			queue_free()
		return
	
	stats.connect("health_changed", self, "on_health_changed")
	
	if rotation_mode == ROTATIONS.TOWARD_HITBOX:
		var hurtbox = entity.components["hurtbox"]
		if hurtbox != null:
			hurtbox.connect("got_hit", self, "hurtbox_got_hit")
		else:
			push_error("spawner can't rotate_away_from_me because hurtbox was not found")

func on_health_changed(_type, result, _net):
	match result:
		"hurt": if spawn_on_hurt == true: spawn()
		"block": if spawn_on_block == true: spawn()
		"heal": if spawn_on_heal == true: spawn()

func hurtbox_got_hit(by_area, type):
	var src_entity = by_area.get_parent()
	#if src_entity is Attack:
	#	src_entity = src_entity.SOURCE
	
	trigger_pos = src_entity.global_position

func spawn():
	if thing == null and standby_mode == false:
		push_error(entity.get_name()+"'s spawners's 'thing' was not set")
		queue_free()
		return
	
	if global.nodes["ysort"] == null:
		push_error("global.nodes['ysort'] == null")
		return
	
	var new_thing: Node2D = thing.instance()
	
	new_thing.global_position = entity.global_position + Vector2(
			rand_range(-random_position_offset, random_position_offset), 
			rand_range(-random_position_offset, random_position_offset)
	)
	
	if new_thing is Particles2D and "max_lifetime" in new_thing:
		new_thing.one_shot = particle_one_shot
		new_thing.amount = particle_amount
		new_thing.speed_scale = particle_speed_scale
	
	if use_modulate == true:
		new_thing.modulate = modulate
	
	if rotation_mode == ROTATIONS.TOWARD_HITBOX:
		if trigger_pos != null:
			new_thing.rotation_degrees = rad2deg(
					entity.global_position.direction_to(trigger_pos).angle())
			
		else:
			push_warning("spawner could not do rotate towards hitbox because trigger_pos == null")
	
	elif rotation_mode == ROTATIONS.TOWARD_CURSOR:
		new_thing.rotation_degrees = rad2deg(
				entity.global_position.direction_to(entity.get_global_mouse_position()).angle())
	
	if new_thing is Effect:
		var sprite = new_thing.get_node(new_thing.sprite) as Sprite
		
		if sprite == null:
			push_error("effect sprite could not be found")
			return
		
		if effect_texture != null:
			sprite.texture = effect_texture
	
		sprite.hframes = effect_hframes
		sprite.vframes = effect_vframes
		
		var my_sprite = entity.components["entity_sprite"] as Sprite
		if my_sprite != null and effect_inherit_flipping == true:
			sprite.flip_h = my_sprite.flip_h
			sprite.flip_v = my_sprite.flip_v
	
	if new_thing is Entity:
		if entity_inherit_velocity == true:
			new_thing.velocity = entity.velocity
	
	global.nodes["ysort"].call_deferred("add_child", new_thing)
