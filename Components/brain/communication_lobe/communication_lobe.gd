extends Node

onready var brain = get_parent()
onready var delay_timer = $delay_timer

export var TARGET_SPREADING = true
export(float, 0.01, 10.0) var DELAY = 1.2
export(float, 0.0, 5.0) var DELAY_VARIANCE = 0.5

var the_target

func _on_communication_lobe_tree_entered():
	get_parent().communication_lobe = self
	if get_parent().get_parent() is Entity:
		get_parent().get_parent().components["communication_lobe"] = self

func _ready() -> void:
	brain.connect("found_target", self, "start_delay")

func start_delay():
	the_target = brain.targets[brain.targets.size()-1]
	delay_timer.wait_time = clamp(DELAY + rand_range(-DELAY_VARIANCE, DELAY_VARIANCE), 0.01, 15.0)
	delay_timer.start()

func _on_delay_timer_timeout() -> void:
	if the_target == null: return
	
	# search get_overlapping_bodies() for allies to communicate with
	for body in brain.sight.get_overlapping_bodies():
		if (
			body is Entity
			and body.get_name() != "world_tiles"
			and body.components["brain"] != null
			and brain.los_check(body) == true
			and global.get_relation(brain.get_parent(), body) == "friendly"
			and not body.components["brain"].targets.has(the_target)
			and body.components["memory_lobe"] != null
			and not body.components["memory_lobe"].memory_id.has(the_target.get_instance_id())
		):
			# PROBLEM_NOTE: im 90% sure this is never called
			body.components["brain"].add_target(the_target, true)
				
#			if body.components["memory_lobe"] != null and body.components["movement_lobe"] != null:
#			body.components["memory_lobe"].add_memory(the_target.global_position,
#			body.components["movement_lobe"].get_spring(the_target), the_target.get_instance_id())
