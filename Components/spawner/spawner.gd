extends Node

enum ROTATIONS {
	KEEP = -1,
	TOWARD_HITBOX,
	TOWARD_CURSOR,
	TOWARD_BRAIN_TARGET
}

export(bool) var standby_mode = false # requires 'thing' to be set

export(PackedScene) var thing
export var thing_path: String
export(bool) var spawn_on_free = true
export(bool) var spawn_on_hurt = false
export(bool) var spawn_on_block = false
export(bool) var spawn_on_heal = false
export(ROTATIONS) var rotation_mode = ROTATIONS.KEEP
export(int, 1, 99) var spawns := 1

export var use_modulate = false
export(Color) var modulate
export(Vector2) var position_offset := Vector2.ZERO
export(int) var random_position_offset = 0

export(Texture) var effect_texture
export var effect_inherit_texture := false
export(Vector2) var effect_frames := Vector2(-1, -1)
export(bool) var effect_inherit_flipping = true

export(bool) var particle_one_shot = true
export(int, 1) var particle_amount = 5
export(float, 0, 64) var particle_speed_scale = 1.0

export(bool) var entity_inherit_velocity := false
export(float, 0, 1000) var entity_random_velocity := 0 

export(int) var stats_damage_mod: int
export(int) var stats_true_damage_mod: int

export(Dictionary) var custom_properties := {
	#property: value
}

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
	
	if thing == null and thing_path != null:
		thing = load(thing_path)

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
	
	if refs.ysort.get_ref() == null:
		push_error("ysort == null")
		return
	
	var new_thing: Node2D = thing.instance()
	
	new_thing.global_position = entity.global_position + Vector2(
			rand_range(-random_position_offset, random_position_offset), 
			rand_range(-random_position_offset, random_position_offset)
	) + position_offset
	
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
				entity.global_position.direction_to(global.get_look_pos()).angle()
		)
	
	elif rotation_mode == ROTATIONS.TOWARD_BRAIN_TARGET:
		var brain = entity.components["brain"]
		if brain.targets.size() > 0:
			new_thing.rotation_degrees = rad2deg(
				entity.components["brain"].get_closest_target().global_position.direction_to(
					entity.global_position
				)
			)
	
	if new_thing is Effect:
		var sprite: Sprite = new_thing.get_node(new_thing.sprite)
		
		if sprite == null:
			push_error("effect sprite could not be found")
			return
		
		if effect_texture != null:
			sprite.texture = effect_texture
		elif effect_inherit_texture == true:
			sprite.texture = entity.components["entity_sprite"].texture
		
		if effect_frames != Vector2(-1, -1):
			sprite.hframes = effect_frames.x
			sprite.vframes = effect_frames.y
		
		var my_sprite = entity.components["entity_sprite"] as Sprite
		if my_sprite != null and effect_inherit_flipping == true:
			sprite.flip_h = my_sprite.flip_h
			sprite.flip_v = my_sprite.flip_v
	
	if new_thing is Entity:
		if entity_inherit_velocity == true:
			new_thing.velocity = entity.velocity
		
		if entity_random_velocity > 0:
			var direction := Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized()
			new_thing.velocity += Vector2(
				rand_range(-entity_random_velocity, entity_random_velocity),
				rand_range(-entity_random_velocity, entity_random_velocity)
			) * direction
		
		if stats_damage_mod != 0 or stats_true_damage_mod != 0:
			var component: Node = new_thing.find_node("stats")
			if component == null:
				component = new_thing.find_node("hitbox")
			if component != null:
				component.DAMAGE += stats_damage_mod
				component.TRUE_DAMAGE += stats_true_damage_mod
			else:
				push_error("spawner couldn't find stats or hitbox to apply damage mod to")
	
	for property in custom_properties.keys():
		new_thing.set(property, custom_properties[property])
		
	
	refs.ysort.get_ref().call_deferred("add_child", new_thing)
	
	spawns -= 1
	
	if spawns > 0:
		spawn()
