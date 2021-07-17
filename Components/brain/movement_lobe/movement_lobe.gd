extends Node2D

const PATH_DIST := 8

onready var idle_timer = $idle_timer
onready var wander_timer = $wander_timer
onready var movement_timer = $movement_timer
onready var brain = get_parent()
onready var entity = brain.get_parent()

export var IDLE_TIME = 0.8
export var IDLE_OFFSET = 0.4
export var WANDER_TIME = 0.8
export var WANDER_OFFSET = 0.4
export(float, 0.0, 1.0) var WANDER_SPEED := 0.6
export(float, 0, 999) var WANDER_RANGE = 80 # max range from starting pos it can wander from
export var SMART_SLOWDOWN = true # starts slowing down before reaching distination to avoid overshooting
export var EIGHT_WAY_MOVEMENT = false # can only move in eight directions like wasd controls
export(int, 1, 60) var MOVEMENT_EFFICIENCY = 15 # times per second input_vector is updated

export var general_springs = {
	"friendly": "",
	"neutral": "",
	"hostile": "default_spring"
}
export var faction_springs = {}
export var entity_springs = {}
var springs = {}

var guard_pos = Vector2.ZERO
var guard_path = null
var wander_pos = Vector2.ZERO
var wander_path = null
var best_position_paths = []

var strafe_dir = 0
var strafe_change = 1

# PROBLEM_NOTE: it would probably be alot more streamlined to have a state variable
# it could also probably fix the bug where sometimes enemies won't wander

func _on_movement_lobe_tree_entered() -> void:
	get_parent().movement_lobe = self
	if get_parent().get_parent() is Entity:
		get_parent().get_parent().components["movement_lobe"] = self

func _ready() -> void:
	guard_pos = global_position
	idle_timer.wait_time = IDLE_TIME
	wander_timer.wait_time = WANDER_TIME
	movement_timer.wait_time = 1.0 / MOVEMENT_EFFICIENCY
	movement_timer.start()
	
	if entity.components["sleeper"] != null:
		entity.components["sleeper"].connect("awoken", self, "awoken")
	
	# setting springs (replacing strings with paths to the spring node)
	for child in get_children():
		if child is Node:
			springs[child.get_name()] = child
	
	for general_spring in general_springs:
		general_spring = springs.get(general_spring)
		
	if faction_springs != {}:
		for faction_spring in faction_springs:
			faction_spring = springs.get(faction_spring)
	
	if entity_springs != {}:
		for entity_spring in entity_springs:
			entity_spring = springs.get(entity_spring)

func update_path(path: PoolVector2Array, end_pos: Vector2) -> PoolVector2Array:
	if entity.components["sleeper"] != null and entity.components["sleeper"].is_on_screen() == false:
		return path
	
	if path.size() <= 2 or entity.velocity == Vector2.ZERO:
		path = get_tree().current_scene.pathfind(global_position, end_pos)
	
	if path.size() > 0 and global_position.distance_to(path[0]) < PATH_DIST:
		if brain.los_check(path[0], false) == true:
			path.remove(0)
	
	return path

func _on_idle_timer_timeout() -> void:
	wander_timer.wait_time = clamp(WANDER_TIME + rand_range(-(WANDER_OFFSET), WANDER_OFFSET), 0.01, 999.0)
	if brain.targets != []: return
	
	var ss = get_world_2d().direct_space_state
	var position_tries := 0
	while (
		position_tries == 0 or 
		ss.intersect_point(Vector2(wander_pos), 1, [], 33).has("collider") and
		position_tries < max(MOVEMENT_EFFICIENCY/3, 1)
	):
		wander_pos = global_position + (Vector2(rand_range(-1,1),rand_range(-1,1)).normalized()*100)
		position_tries += 1
	if brain.los_check(wander_pos, false) == true:
		entity.input_vector = global_position.direction_to(wander_pos).normalized()
	elif wander_path == null:
		wander_path = update_path(PoolVector2Array(), wander_pos)
	elif wander_path is PoolVector2Array:
		wander_path = update_path(wander_path, wander_pos)
		
		var tries := 0
		while wander_path.size() < 2 and tries < max(MOVEMENT_EFFICIENCY/3, 1):
			tries += 1
			
			wander_pos = global_position + (Vector2(rand_range(-1,1),rand_range(-1,1)).normalized()*100)
			
			if ss.intersect_point(Vector2(wander_pos), 1, [], 33).has("collider"):
				continue
			else:
				wander_path = update_path(wander_path, wander_pos)
		
		if wander_path.size() > 1:
			entity.input_vector = (
				global_position.direction_to(wander_path[0]).normalized() * WANDER_SPEED
			)
	
	if global_position.distance_to(guard_pos) > WANDER_RANGE: 
		# wander back to guard pos
		if brain.los_check(guard_pos, false) == true:
			entity.input_vector = global_position.direction_to(guard_pos).normalized()
			guard_path = null
		else:
			if guard_path == null:
				guard_path = update_path(PoolVector2Array(), guard_pos)
			elif guard_path is PoolVector2Array:
				guard_path = update_path(guard_path, guard_pos)
			
			if guard_path.size() > 0:
				entity.input_vector = global_position.direction_to(guard_path[0]).normalized()
	else:
		guard_path = null
	
	wander_timer.start()

func _on_wander_timer_timeout() -> void:
	idle_timer.wait_time = clamp(IDLE_TIME + rand_range(-(IDLE_OFFSET), IDLE_OFFSET), 0.01, 999.0) 
	if brain.targets != []: return
	if not global_position.distance_to(guard_pos) > WANDER_RANGE*1.5: 
		entity.input_vector = Vector2.ZERO
	idle_timer.start()

func awoken():
	entity.input_vector = Vector2.ZERO
	idle_timer.stop()
	wander_timer.start()

func get_spring(target:Entity):
	var spring = null
	
	if global.get_relation(entity, target) != "":
		spring = general_springs.get(global.get_relation(entity, target))
	if faction_springs.has(target.faction):
		spring = faction_springs.get(target.faction)
	if entity_springs.has(target.truName):
		spring = entity_springs.get(target.truName)
	if entity.marked_enemies.has(target):
		spring = general_springs["hostile"]
	
	if spring == "": 
		spring = null
	
	return springs.get(spring)

func early_slowdown(destination: Vector2):
	if SMART_SLOWDOWN == false:
		return false
	else:
		if global_position.distance_to(destination) <= 0.01666 * entity.SLOWDOWN:
			return true
		else:
			return false

# PROBLEM_NOTE: i think this is the single most intensive function in the whole game so maybe optimize it
func _on_movement_timer_timeout() -> void:
	var intention = Vector2.ZERO
	var trigger_anti_stuck: bool = true
	
	if brain.targets == []: # no targets
		# for adjusting guard_path
		if brain.memory_lobe == null or brain.memory_lobe.memory == [] and guard_path != null:
				if global_position.distance_to(guard_pos) > WANDER_RANGE:
					if guard_path == null:
						guard_path = update_path(PoolVector2Array(), guard_pos)
					else:
						guard_path = update_path(guard_path, guard_pos)
					if guard_path.size() != 0:
						entity.input_vector = global_position.direction_to(guard_path[0]).normalized()
					
					return
			
				# adjusting wander_path
				elif wander_timer.time_left == 0 and wander_path != null:
					wander_path = update_path(wander_path, wander_pos)
					if wander_path.size() != 0:
						entity.input_vector = global_position.direction_to(wander_path[0]).normalized()
					
					return
		
		# change intention based on memories
		if brain.memory_lobe != null:
			for i in range(brain.memory_lobe.memory.size()-1, -1, -1):
				var this_memory = brain.memory_lobe.memory[i]
				var spring = brain.memory_lobe.memory_springs[i]
				
				var target_to_me = this_memory.direction_to(global_position).normalized()
				var best_position = this_memory + target_to_me * spring.DISTANCE
				
				var strength = brain.SIGHT_RANGE / global_position.distance_to(best_position)
				
				if brain.los_check(best_position, false) == true:
					brain.memory_lobe.memory_paths[i] = null
					if spring.INVERT_DISTANCE == false:
						intention += global_position.direction_to(best_position) * strength
					else:
						intention += global_position.direction_to(best_position) * -1 * strength
				else:
					var path = brain.memory_lobe.memory_paths[i]
					if path == null:
						path = update_path(PoolVector2Array(), best_position)
					elif path is PoolVector2Array:
						path = update_path(path, best_position)
					
					brain.memory_lobe.memory_paths[i] = path
					
					if path.size() > 0:
						if spring.INVERT_DISTANCE == false:
							intention += global_position.direction_to(path[0]).normalized() * strength
						else:
							intention += global_position.direction_to(path[0]).normalized() * -1 * strength
				
				if strength > 0: trigger_anti_stuck = false
	
	else: # has target(s)
		for i in range(brain.targets.size()-1, -1, -1):
			var target = brain.targets[i]
			if get_node_or_null(brain.target_paths[i]) == null:
				brain.remove_target(target)
			elif get_spring(target) != null:
				var spring = get_spring(target)
				
				var target_to_me = target.global_position.direction_to(global_position).normalized()
				if spring.STRAFING == true:
					if strafe_change == 1 and strafe_dir == spring.STAFE_STUTTER: strafe_change = -1
					elif strafe_change == -1 and strafe_dir == -spring.STAFE_STUTTER: strafe_change = 1
					strafe_dir += strafe_change
					
					if strafe_dir != 0:
						target_to_me = Vector2(target_to_me.y, target_to_me.x)
					if strafe_dir < 0:
						target_to_me *= -1
					
				var best_position = target.global_position + target_to_me * spring.DISTANCE
				
				# accounting for DISTANCE_RANGE
				if spring.USE_DISTANCE_RANGE == true:
					var dist: float = global_position.distance_to(target.global_position)
					if abs(dist - spring.DISTANCE_MIN) <= abs(dist - spring.DISTANCE_MAX):
						best_position = target.global_position + target_to_me * spring.DISTANCE_MIN
					else:
						best_position = target.global_position + target_to_me * spring.DISTANCE_MAX
				
				var strength = 0
				if global_position.distance_to(best_position) != 0: 
					strength = brain.SIGHT_RANGE / global_position.distance_to(best_position)
				else:
					strength = brain.SIGHT_RANGE / (global_position.distance_to(best_position)+0.01) 
				
				if early_slowdown(best_position) == true: strength = 0 # PROBLEM_NOTE: this causes flicker
				
				if spring.USE_DEADZONE == true:
					if spring.DEADZONE >= global_position.distance_to(best_position):
						strength = 0
				if spring.USE_FARZONE == true:
					if spring.FARZONE <= global_position.distance_to(best_position):
						strength = 0
				if brain.los_check(best_position, false) == true:
					#best_position_paths[i] = null
					if spring.INVERT_DISTANCE == false:
						intention += global_position.direction_to(best_position) * strength
					else:
						intention += global_position.direction_to(best_position) * -1 * strength
				else:
					var path = best_position_paths[i]
					
					if path == null:
						path = update_path(PoolVector2Array(), best_position)
					elif path is PoolVector2Array:
						path = update_path(path, best_position)
					
					if path == null or path.size() < 2:
						continue
					
					best_position_paths[i] = path
					
					if spring.INVERT_DISTANCE == false:
						intention += global_position.direction_to(path[0]) * strength
					else:
						intention += global_position.direction_to(path[0]) * -1 * strength
				
				if strength > 0: trigger_anti_stuck = false
	
	if brain.memory_lobe != null and brain.targets == [] and brain.memory_lobe.memory == []: return
	
	# anti-stuck
	if intention == Vector2.ZERO and not brain.targets.size() < 2 and trigger_anti_stuck == true: 
		intention = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized()
	
	intention = intention.normalized()
	
	entity.input_vector = intention
