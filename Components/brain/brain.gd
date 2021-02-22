extends Node2D

const LOS_MASK = 3

onready var think_timer = $think_timer
onready var sight = $sight
onready var sight_shape = $sight/CollisionShape2D
var movement_lobe
var action_lobe
var memory_lobe
var warning_lobe 
var communication_lobe

export var DEBUG_DRAW = false

export(int, 0, 20) var TOLERANCE = 3 # the amount of times it will tolerate friendly fire before infighting
export(float, 0.01666, 3.0) var THINK_TIME = 0.1
export(float, 0, 200) var SIGHT_RANGE = 100
export(int, 1, 99) var MAX_TARGETS = 5
export var COMMUNICATES = true
export(float, 0.01, 10.0) var COMM_DELAY = 1.2
export(float, 0.0, 5.0) var COMM_DELAY_VARIANCE = 0.5

var targets = []
var target_paths = []

signal found_target
signal lost_target
signal think

func _on_brain_tree_entered() -> void:
	if get_parent() is Entity:
		get_parent().components["brain"] = self

func _ready():
	sight_shape.shape.radius = SIGHT_RANGE
	think_timer.wait_time = THINK_TIME

func _draw():
	if DEBUG_DRAW == false: return
	
	draw_line(position, position + get_parent().input_vector * 16, Color.orange, 2.5)
	
	if memory_lobe != null:
		for i in memory_lobe.memory.size():
			draw_circle(to_local(memory_lobe.memory[i]), 2, Color.blue)
			if targets == []:
				if los_check(memory_lobe.memory[i]) == true:
					draw_line(position, to_local(memory_lobe.memory[i]), Color.lightblue, 1.0)
				else:
					var path = get_tree().current_scene.pathfind(global_position, memory_lobe.memory[i])
					if path.size() < 2: path = [position, Vector2.ZERO]
					for x in path.size(): path[x] = to_local(path[x])
					draw_multiline(path, Color.lightblue)
	
	if movement_lobe != null:
		for i in targets.size():
			var target = targets[i]
			if is_target_valid(i) == true:
				var spring = movement_lobe.get_spring(target)
	
				var best_position = Vector2.ZERO
				var target_to_me = target.global_position.direction_to(global_position).normalized()
				best_position = target.global_position + target_to_me * spring.DISTANCE
	
				if los_check(best_position) == true:
					draw_line(position, to_local(best_position), Color.red, 1, false)
				else:
					#var path = get_tree().current_scene.pathfind(global_position, best_position)
					#if path.size() < 2: path = [Vector2.ZERO, Vector2.ZERO]
					var path = movement_lobe.best_position_paths[i]
					if path != null and path.size() > 1:
						for x in path.size(): path[x] = to_local(path[x])
						draw_multiline(path, Color.red, 1.5)
		
		if targets == [] and memory_lobe == null or memory_lobe.memory == []:
			draw_circle(to_local(movement_lobe.guard_pos), movement_lobe.WANDER_RANGE, Color8(255, 255, 0, 50))
			if movement_lobe.guard_path == null:
				draw_line(position, to_local(movement_lobe.guard_pos), Color.yellow, 1, false)
			else:
				var path = movement_lobe.guard_path
				if path.size() < 2: path = [Vector2.ZERO, Vector2.ZERO]
				for i in path.size(): path[i] = to_local(path[i])
				draw_multiline(path, Color.yellow, 1, false)
				draw_circle(path[0], 1.5, Color.yellow)

func closest_target():
	var target = "no target found from closest_target()"
	var dist = 999
	for i in targets.size():
		if is_target_valid(i):
			if global_position.distance_to(targets[i].global_position) < dist:
				target = targets[i]
				dist = global_position.distance_to(targets[i].global_position)
	return target

func is_target_valid(index: int): # maybe make this work with the target node OR target index
	if index > targets.size() - 1: 
		return false
		
	var target = targets[index]
	if target == null:
		return false
	elif get_node_or_null(target_paths[index]) == null:
		return false
	elif target.is_queued_for_deletion() == true:
		return false
	elif los_check(target) == false and not global_position.distance_to(target.global_position) < 5:
		return false
	else:
		return true

func los_check(target):
	var target_pos = target
	if target is Entity: target_pos = target.global_position
	var ss = get_world_2d().direct_space_state
	
	var vision = ss.intersect_ray(target_pos, global_position, [get_parent()], LOS_MASK)
	if vision == null: return null
	else: vision = ss.intersect_ray(global_position.move_toward(target_pos, 2.5),
	target_pos, [get_parent()], LOS_MASK)
	
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

func add_target(tar: Node, force = true):
	if not tar is Entity or tar is Melee or tar is Projectile or tar is Item or tar == get_parent(): return
	if movement_lobe != null and movement_lobe.get_spring(tar) == null: return
	
	targets.append(tar)
	target_paths.append(tar.get_path())
	if movement_lobe != null: movement_lobe.best_position_paths.append(null)
	
	if is_target_valid(targets.size()-1) == false and force == false:
		targets.remove(targets.size()-1)
		target_paths.remove(target_paths.size()-1)
		return
	
	if movement_lobe != null:
		movement_lobe.idle_timer.stop()
		movement_lobe.wander_timer.stop()
	
	emit_signal("found_target")
	
	var effect = global.aquire("exclaimation")
	get_parent().get_parent().call_deferred("add_child", effect)
	effect.global_position = global_position.move_toward(tar.global_position, 32)

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
			if get_parent().is_queued_for_deletion() == true: return
			movement_lobe.best_position_paths.remove(target_id)
			memory_lobe.add_memory(targets[target_id].global_position, 
			movement_lobe.get_spring(targets[target_id]), targets[target_id].get_instance_id())
			
			var effect = global.aquire("question")
			get_parent().get_parent().call_deferred("add_child", effect)
			effect.global_position = global_position.move_toward(targets[target_id].global_position, 32)
		
	targets.remove(target_id)
	target_paths.remove(target_id)
	emit_signal("lost_target")
	
	if targets == []: 
		get_parent().input_vector = Vector2.ZERO
		if movement_lobe != null and movement_lobe.wander_timer.is_inside_tree() == true:
			movement_lobe.wander_timer.start()

func _on_sight_body_entered(body: Node) -> void:
	if los_check(body) == true:
		add_target(body)

func _on_sight_body_exited(body: Node) -> void:
	remove_target(body)

func _on_think_timer_timeout() -> void:
	think_timer.wait_time = THINK_TIME + rand_range(-0.1, 0.1)
	if get_parent().is_physics_processing() == false: return
	emit_signal("think")
	
	# search get_overlapping_bodies() for new targets
	for body in sight.get_overlapping_bodies():
		if body is Entity and body.get_name() != "WorldTiles" and not targets.has(body):
			if los_check(body) == true:
				add_target(body)
	
	#if movement_lobe == null:
	for i in targets.size():
		if is_target_valid(i) == false:
			remove_target(i)
	
	if DEBUG_DRAW == true:
		update()
	
	#if targets != []: print(is_target_valid(0))
