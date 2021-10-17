extends Node2D

onready var think_timer = $think_timer
onready var sight = $sight
onready var sight_shape = $sight/CollisionShape2D
var movement_lobe: Node
var action_lobe: Node
var memory_lobe: Node
var warning_lobe: Node
var communication_lobe: Node

export(int, 0, 20) var TOLERANCE = 2 # the amount of times it will tolerate friendly fire before infighting
export(float, 0.01666, 1.0) var THINK_TIME = 0.1
export(float, 0, 300) var SIGHT_RANGE = 100
export(int, 1, 99) var MAX_TARGETS = 5
export(bool) var SIGHT_EFFECTS := true
# PROBLEM_NOTE: idk why this is in the brain
export var COMMUNICATES = true
export(float, 0.01, 10.0) var COMM_DELAY = 1.2
export(float, 0.0, 5.0) var COMM_DELAY_VARIANCE = 0.5

export var IGNORE_ATTACKS := true
export var IGNORE_INANIMATE := true
export var IGNORE_UNFACTIONED := true
export var IGNORE_ALLIES := true
export var BLACKLIST := []
var excluded := [] # list of entities that can never be targets

# PROBLEM_NOTE: it would be better to use a dictionary for targets and target_paths because the targets
# are not accesed or removed in a set order. same goes for some stuff in movement_lobe.gd i think 
var targets := []
var target_paths := []
var entities := []
var entity: Entity

signal found_target
signal lost_target
signal think

func _on_brain_tree_entered():
	entity = get_parent()
	entity.components["brain"] = self

func _ready():
	sight_shape.shape.radius = SIGHT_RANGE
	think_timer.wait_time = THINK_TIME
	
	excluded.append(weakref(entity))

# for debugging purposes:
#func _draw():
#	draw_line(position, position + entity.input_vector * 8, Color.orange, 1.4)
#
#	if memory_lobe != null:
#		for i in memory_lobe.memory.size():
#			draw_circle(to_local(memory_lobe.memory[i]), 2, Color.blue)
#			if targets == []:
#				if los_check(memory_lobe.memory[i], false) == true:
#					draw_line(position, to_local(memory_lobe.memory[i]), Color.lightblue, 1.0)
#				else:
#					var path = get_tree().current_scene.pathfind(global_position, memory_lobe.memory[i])
#					if path.size() < 2: path = [position, Vector2.ZERO]
#					for x in path.size(): path[x] = to_local(path[x])
#					draw_multiline(path, Color.lightblue)
#
#	if movement_lobe != null:
#		for i in targets.size():
#			var target = targets[i]
#			if is_target_valid(i) == true:
#				var spring = movement_lobe.get_spring(target)
#
#				var best_position = Vector2.ZERO
#				var target_to_me = target.global_position.direction_to(global_position).normalized()
#				# Internal Script Error! - opcode #0 (report please).
#
#				best_position = target.global_position + target_to_me * spring.DISTANCE
#
#				if los_check(best_position, false) == true:
#					draw_line(position, to_local(best_position), Color.red, 1, false)
#				else:
#					var path = movement_lobe.best_position_paths[i]
#					if path != null and path.size() > 1:
#						for x in path.size(): path[x] = to_local(path[x])
#						draw_multiline(path, Color.red, 1.5)
#						for point in path:
#							draw_circle(point, 1, Color.red)
#
#		if targets == [] and (memory_lobe == null or memory_lobe.memory == []):
#			draw_circle(to_local(movement_lobe.guard_pos), movement_lobe.WANDER_RANGE, Color8(255, 255, 0, 50))
#			if movement_lobe.guard_path == null:
#				draw_line(position, to_local(movement_lobe.guard_pos), Color.yellow, 1, false)
#			else:
#				var path = movement_lobe.guard_path
#				if path.size() < 2: path = [Vector2.ZERO, Vector2.ZERO]
#				for i in path.size(): path[i] = to_local(path[i])
#				draw_multiline(path, Color.yellow, 1, false)
#				draw_circle(path[0], 1.5, Color.yellow)

func get_closest_target(exclude_self:=true) -> Entity:
	# PROBLEM_NOTE: make \/ this string more simple so it's easier to check for it (probably just use null or "")
	var target: Entity
	var dist = 999
	for i in targets.size():
		if get_node_or_null(target_paths[i]) != null:
			if exclude_self == true and targets[i] == entity:
				continue
			elif global_position.distance_to(targets[i].global_position) < dist:
				target = targets[i]
				dist = global_position.distance_to(targets[i].global_position)
	return target 

func is_target_valid(index: int) -> bool: # maybe make this work with the target node OR target index
	if index > targets.size() - 1 or index > target_paths.size() -1:
		return false
	
	var target = targets[index]
	
	if get_node_or_null(target_paths[index]) == null:
		return false
	elif target.is_queued_for_deletion() == true:
		return false
	elif target in entity.marked_allies and IGNORE_ALLIES == true:
		return false
	elif los_check(target) == false and not global_position.distance_to(target.global_position) < 5:
		return false
	else:
		return true

func los_check(target, ignore_low_barriers:=true):
	var mask := 3
	if ignore_low_barriers == false:
		mask += 32
	
	var target_pos = target
	if target is Entity:
		target_pos = target.global_position
	
	var excludes := []
	for i in range(excluded.size()-1, -1, -1):
		var excluded_entity = excluded[i].get_ref()
		if excluded_entity == null:
			excluded.remove(i)
		elif not (target is Entity and entity == target):
			excludes.append(excluded_entity)
	
	var ss = get_world_2d().direct_space_state
	var vision = ss.intersect_ray(target_pos, global_position, excludes, mask)
	
	while vision and vision.collider is Entity and vision.collider.global_position != target_pos:
		excludes.append(vision.collider)
		
		vision = ss.intersect_ray(target_pos, global_position, excludes, mask)
	
	if vision == {}:
		return false
	else:
		vision = ss.intersect_ray(global_position.move_toward(target_pos, 2.5), target_pos, excludes, mask)
	
	if vision:
		if vision.collider is TileMap:
			return false
		elif target is Entity and vision.collider == target:
			return true
		elif target is Vector2 and vision.collider.global_position == target:
			return true
		else:
			return false
	else:
		if target is Entity:
			return false
		elif target is Vector2:
			return true

func add_target(tar: Entity, force = false) -> void:
	if (
		not tar == entity and
		(movement_lobe != null and movement_lobe.get_spring(tar) == null) or
		force == false and
		(tar is Attack and IGNORE_ATTACKS == true) or
		(tar.faction == "" and IGNORE_UNFACTIONED == true) or
		(tar.INANIMATE == true and IGNORE_INANIMATE == true) or
		tar.truName in BLACKLIST or tar.faction in BLACKLIST or
		(global.get_relation(entity, tar) == "friendly" and IGNORE_ALLIES == true)
	):
		excluded.append(weakref(tar))
		return
	elif targets.size() >= MAX_TARGETS: # dont want to exclude an entity just because it was at max
		return
	
	targets.append(tar)
	target_paths.append(tar.get_path())
	if movement_lobe != null:
		movement_lobe.best_position_paths.append(null)
	
	if is_target_valid(targets.size()-1) == false and force == false:
		targets.pop_back()
		target_paths.pop_back()
		if movement_lobe != null:
			movement_lobe.best_position_paths.pop_back()
		return
	
	if movement_lobe != null:
		movement_lobe.idle_timer.stop()
		movement_lobe.wander_timer.stop()
	
	emit_signal("found_target")
	
	spawn_effect("exclaimation", global_position.move_toward(tar.global_position, 32))

func remove_target(tar):
	if targets == []: return
	
	var target = null
	var target_id = 0
	if tar is int and not targets.size()-1 < tar:
		target_id = tar
		target = targets[target_id]
	elif tar is Node:
		target = tar
		target_id = targets.find(target)
	
	if target_id == -1 or target == null: return
	
	if movement_lobe != null and memory_lobe != null:
		if movement_lobe.get_spring(targets[target_id]) != null and memory_lobe.MEMORY_TIME > 0:
			if get_node_or_null(target_paths[target_id]) == null: return
			if entity.is_queued_for_deletion() == true: return
			
			movement_lobe.best_position_paths.remove(target_id)
			memory_lobe.add_memory(targets[target_id].global_position, 
					movement_lobe.get_spring(targets[target_id]), 
					targets[target_id].get_instance_id())
			
			spawn_effect("question", global_position.move_toward(targets[target_id].global_position, 32))
	
	targets.remove(target_id)
	target_paths.remove(target_id)
	emit_signal("lost_target")
	
	if targets == []: 
		entity.input_vector = Vector2.ZERO
		if movement_lobe != null and movement_lobe.wander_timer.is_inside_tree() == true:
			movement_lobe.wander_timer.start()

func _on_sight_body_entered(body: Node) -> void:
	if (
		body is Entity and
		not body == entity and
		not body in entities and
		not (body is Attack and IGNORE_ATTACKS == true) and
		not (body.faction == "" and IGNORE_UNFACTIONED == true) and
		not (body.INANIMATE == true and IGNORE_INANIMATE == true) and
		not (body.truName in BLACKLIST or body.faction in BLACKLIST) and
		not (global.get_relation(entity, body) == "friendly" and IGNORE_ALLIES == true)
	):
		entities.append(body)
	
	if body.is_queued_for_deletion() == false and los_check(body) == true:
		add_target(body)

func _on_sight_body_exited(body: Node) -> void:
	var body_id = entities.find(body)
	if body_id != -1:
		entities.remove(body_id)
	
	remove_target(body)

func _on_think_timer_timeout() -> void:
	#return
	think_timer.wait_time = THINK_TIME + rand_range(-0.1, 0.1)
	
	if entity.components["sleeper"] != null:
		if entity.components["sleeper"].active == false:
			return
	
	emit_signal("think")
	
	# search entities (array of all entities in range) for new targets
	for body in entities:
		if not targets.has(body) and body.is_queued_for_deletion() == false:
			add_target(body)
	
	for i in targets.size():
		if is_target_valid(i) == false:
			remove_target(i)

# this is for debugging purposes
#func _process(delta: float) -> void:
#	if OS.is_debug_build() == true and has_method("_draw"):
#		update()

func spawn_effect(effect: String, pos: Vector2):
	if SIGHT_EFFECTS == false:
		return
	
	var new_effect = res.aquire_effect(effect)
	if not new_effect is Effect:
		push_warning("effect was invalid")
		return
	
	refs.ysort.get_ref().call_deferred("add_child", new_effect)
	new_effect.global_position = pos

func get_target_names() -> Array:
	var names := []
	for target in targets:
		names.append(target.get_name())
	return names
