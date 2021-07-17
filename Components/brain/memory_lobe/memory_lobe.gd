extends Node

onready var brain = get_parent()
onready var entity = brain.get_parent()
onready var memory_timer = $memory_timer

export(float, 0, 25.0) var MEMORY_TIME = 4.0

var memory = []
var memory_id = []
var memory_springs = []
var mem_times_queue = []
var memory_paths = []

func _on_memory_lobe_tree_entered():
	get_parent().memory_lobe = self
	get_parent().connect("think", self, "remove_irrelevant_memories")
	if get_parent().get_parent() is Entity:
		get_parent().get_parent().components["memory_lobe"] = self

func _ready() -> void:
	memory_timer.wait_time = MEMORY_TIME
	
	if entity.components.has("hurtbox"):
		entity.components["hurtbox"].connect("got_hit", self, "got_hit")

func add_memory(pos: Vector2, spring: Node, id: int):
	if brain.get_parent().is_queued_for_deletion() == true: return
	
	# removes previous memory with matching id
	for i in memory_id.size():
		if memory_id[i] == id: 
			remove_memory(i)
			break
	
	if brain.movement_lobe != null:
		brain.movement_lobe.idle_timer.stop()
		brain.movement_lobe.wander_timer.stop()
	
	memory.push_front(pos)
	memory_springs.push_front(spring)
	memory_paths.push_front(null)
	memory_id.push_front(id)
	
	if memory_timer.time_left == 0:
		if memory_timer.is_inside_tree() == true:
			memory_timer.start()
	else:
		mem_times_queue.push_front(MEMORY_TIME - memory_timer.time_left)

func remove_memory(i: int):
	if memory.size()-1 < i: return
	memory.remove(i)
	memory_id.remove(i)
	memory_paths.remove(i)
	memory_springs.remove(i)
	if mem_times_queue != []:
		memory_timer.wait_time = mem_times_queue[0] + 0.01
		mem_times_queue.pop_front()
		if memory_timer.is_inside_tree() == false:
			yield(memory_timer, "tree_entered")
		memory_timer.start()
	else:
		memory_timer.wait_time = MEMORY_TIME

func _on_memory_timer_timeout() -> void:
	memory.pop_back()
	memory_id.pop_back()
	memory_paths.pop_back()
	memory_springs.pop_back()
	if mem_times_queue != []:
		memory_timer.wait_time = mem_times_queue[0] + 0.01
		mem_times_queue.pop_front()
		memory_timer.start()
	else:
		memory_timer.wait_time = MEMORY_TIME

func got_hit(body, _type):
	var source = body.get_parent()
	if source == self or brain.targets.has(source): return
	if source is Attack: source = source.SOURCE
	if not source is Entity: return
	if brain.targets.has(source) == true: return
	
	match global.get_relation(brain.get_parent(), source):
		"neutral":
			get_parent().marked_enemies.append(source)
		
		"hostile":
			if brain.los_check(source) == true:
				if brain.movement_lobe != null:
					add_memory(source.global_position, 
						brain.movement_lobe.get_spring(source), source.get_instance_id())
				
				var effect = res.aquire("question").instance()
				entity.call_deferred("add_child", effect)
				effect.global_position = brain.global_position.move_toward(source.global_position, 32)
		
		"friendly":
			brain.TOLERANCE -= 1
			if brain.TOLERANCE <= 0:
				brain.get_parent().marked_enemies.append(source)

func remove_irrelevant_memories():
	for i in range(memory.size()-1, -1, -1):
		var this_memory = memory[i]
		var spring = memory_springs[i]
		
		var best_position = Vector2.ZERO
		var target_to_me = this_memory.direction_to(brain.global_position).normalized()
		best_position = this_memory + target_to_me * spring.DISTANCE
		if brain.global_position.distance_to(best_position) < 6 and brain.los_check(best_position) == true:
			remove_memory(i)
