extends Node2D

onready var idle_timer = $idle_timer
onready var wander_timer = $wander_timer
onready var movement_timer = $movement_timer
onready var brain = get_parent()

export var IDLE_TIME = 0.8
export var IDLE_OFFSET = 0.4
export var WANDER_TIME = 0.8
export var WANDER_OFFSET = 0.4
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
var best_position_paths = []

var strafe_dir = 0
var strafe_change = 1

signal debug

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
	
	if brain.get_parent().components["sleeper"] != null:
		brain.get_parent().components["sleeper"].connect("awoken", self, "awoken")
	
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

func _on_idle_timer_timeout() -> void:
	wander_timer.wait_time = clamp(WANDER_TIME + rand_range(-(WANDER_OFFSET), WANDER_OFFSET), 0.01, 999.0)
	if brain.targets != []: return 
	
	var wander_pos = global_position + (Vector2(rand_range(-1,1),rand_range(-1,1)).normalized()*100)
	
	if brain.los_check(wander_pos) == true:
		brain.get_parent().input_vector = global_position.direction_to(wander_pos).normalized()
	else:
		var wander_path = get_tree().current_scene.pathfind(global_position, wander_pos)
		
		while wander_path.size() < 2:
			wander_pos = global_position + (Vector2(rand_range(-1,1),rand_range(-1,1)).normalized()*100)
			wander_path = []
			wander_path = get_tree().current_scene.pathfind(global_position, wander_pos)
			
			# PROBLEM_NOTE: the game crashes with no error message without this. strangely, putting it
			# anywhere in this function before this line will also stop the error, super weird
			# actually, this still causes a (non-fatal) error sometimes. very strange
			debug()
			yield(self, "debug")

		
		brain.get_parent().input_vector = global_position.direction_to(wander_path[1]).normalized()
	
	if global_position.distance_to(guard_pos) > WANDER_RANGE: 
		# wander back to guard pos
		if brain.los_check(guard_pos) == true:
			brain.get_parent().input_vector = global_position.direction_to(guard_pos).normalized()
			guard_path = null
		else:
			if guard_path == null or guard_path.size() < 2:
				guard_path = get_tree().current_scene.pathfind(global_position, guard_pos)
			elif brain.los_check(guard_path[0]) == false:
				guard_path = get_tree().current_scene.pathfind(global_position, guard_pos)
			if guard_path.size() < 2: guard_path = null
			if guard_path != null and global_position.distance_to(guard_path[0]) < 10:
				guard_path.remove(0)
			if guard_path != null and not guard_path.size() < 2:
				brain.get_parent().input_vector = global_position.direction_to(guard_path[0]).normalized()
	else:
		guard_path = null
	
	wander_timer.start()

func _on_wander_timer_timeout() -> void:
	idle_timer.wait_time = clamp(IDLE_TIME + rand_range(-(IDLE_OFFSET), IDLE_OFFSET), 0.01, 999.0) 
	if brain.targets != []: return
	if not global_position.distance_to(guard_pos) > WANDER_RANGE*1.5: 
		brain.get_parent().input_vector = Vector2.ZERO
	idle_timer.start()

func awoken():
	match int(rand_range(0, 1)):
		0:
			idle_timer.start()
			wander_timer.stop()
		1:
			idle_timer.stop()
			wander_timer.start()

func get_spring(target:Entity):
	var spring = null
	
	if global.get_relation(brain.get_parent(), target) != "":
		spring = general_springs.get(global.get_relation(brain.get_parent(), target))
	if faction_springs.has(target.faction):
		spring = faction_springs.get(target.faction)
	if entity_springs.has(target.truName):
		spring = entity_springs.get(target.truName)
	if brain.get_parent().marked_enemies.has(target):
		spring = general_springs["hostile"]
	
	if spring == "": 
		spring = null
	
	return springs.get(spring)

func early_slowdown(destination: Vector2): # PROBLEM_NOTE: clean this up
	if SMART_SLOWDOWN == false:
		return false
	else:
		if global_position.distance_to(destination) <= 0.01666 * brain.get_parent().SLOWDOWN:
			return true
		else:
			return false

# PROBLEM_NOTE: i think this is the single most intensive function in the whole game so maybe optimize it
func _on_movement_timer_timeout() -> void:
	var intention = Vector2.ZERO
	var trigger_anti_stuck = true
	
	if brain.targets == []: # no targets
		
		# for adjusting guard_path
		if brain.memory_lobe != null and brain.memory_lobe.memory == []:
			if guard_path != null:
				if guard_path.size() == 0 or brain.los_check(guard_path[0]) == false:
					guard_path = get_tree().current_scene.pathfind(global_position, 
					brain.movement_lobe.guard_pos)
				if guard_path.size() != 0 and global_position.distance_to(guard_path[0]) < 7:
					guard_path.remove(0)
				if guard_path.size() != 0:
					brain.get_parent().input_vector = global_position.direction_to(guard_path[0]).normalized()
			
			return
		
		if brain.memory_lobe == null: return
		
		# change intention based on memories
		for i in range(brain.memory_lobe.memory.size()-1, -1, -1):
			var this_memory = brain.memory_lobe.memory[i]
			var spring = brain.memory_lobe.memory_springs[i]
			
			var target_to_me = this_memory.direction_to(global_position).normalized()
			var best_position = this_memory + target_to_me * spring.DISTANCE
			
			var strength = brain.SIGHT_RANGE / global_position.distance_to(best_position)
			
			if brain.los_check(best_position) == true:
				brain.memory_lobe.memory_paths[i] = null
				if spring.INVERT_DISTANCE == false:
					intention += global_position.direction_to(best_position) * strength
				else:
					intention += global_position.direction_to(best_position) * -1 * strength
			else:
				var path = brain.memory_lobe.memory_paths[i]
				if path == null or brain.los_check(path[0]) == false:
					path = get_tree().current_scene.pathfind(global_position, best_position)
				if path.size() < 1: path = null
				if path != null and global_position.distance_to(path[0]) < 7:
					path.remove(0)
				if path != null and not path.size() < 1:
					brain.memory_lobe.memory_paths[i] = path
					if spring.INVERT_DISTANCE == false:
						intention += global_position.direction_to(path[0]).normalized() * strength
					else:
						intention += global_position.direction_to(path[0]).normalized() * -1 * strength
			
			if strength > 0: trigger_anti_stuck = false
	
	else: # has target(s)
		for i in range(brain.targets.size()-1, -1, -1):
			var target = brain.targets[i]
			if brain.is_target_valid(i) == false: 
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
					#breakpoint
				var best_position = target.global_position + target_to_me * spring.DISTANCE
				
				var strength = 0
				if global_position.distance_to(best_position) != 0: 
					strength = brain.SIGHT_RANGE / global_position.distance_to(best_position)
				else:
					strength = brain.SIGHT_RANGE / (global_position.distance_to(best_position)+0.1) 
				
				if early_slowdown(best_position) == true: strength = 0 # PROBLEM_NOTE: this causes flicker
				if spring.USE_DEADZONE == true:
					if spring.DEADZONE >= global_position.distance_to(best_position):
						strength = 0
				if spring.USE_FARZONE == true:
					if spring.FARZONE <= global_position.distance_to(best_position):
						strength = 0
				
				if brain.los_check(best_position) == true:
					#best_position_paths[i] = null
					if spring.INVERT_DISTANCE == false:
						intention += global_position.direction_to(best_position) * strength
					else:
						intention += global_position.direction_to(best_position) * -1 * strength
				else:
					var path = best_position_paths[i]
					
					# PROBLEM_NOTE: sometimes the AI will just move back and forth, can't figure out why
					if path != null and path.size() < 2 and global_position.distance_to(path[0]) < 5:
						path.pop_front()
					
					if path == null or path.size() < 2 or brain.los_check(path[0]) == null:
						path = get_tree().current_scene.pathfind(global_position, best_position)
					
					if path.size() < 2:
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
	
	brain.get_parent().input_vector = intention

func debug(): 
	if brain.get_parent().is_queued_for_deletion() == false:
		emit_signal("debug")
