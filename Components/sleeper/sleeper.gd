extends VisibilityEnabler2D

onready var entity := get_parent() as Entity
onready var sleep_timer = $sleep_timer

export(float, 0.01, 60.0) var sleep_delay = 3.0

var active = true

var brain
var has_awoken = false

signal slept
signal awoken

func _on_sleeper_tree_entered():
	get_parent().components["sleeper"] = self

func _ready() -> void:
	if is_on_screen() == false: _on_sleep_timer_timeout()
	
	brain = entity.components["brain"]
	
	sleep_timer.wait_time = sleep_delay
	
	if brain != null:
		brain.connect("found_target", self, "target_found")
		brain.connect("lost_target", self, "target_lost")
	
	var stats = entity.components["stats"]
	if stats != null:
		stats.connect("health_changed", self, "health_changed")

func set_activation(activation: bool, force:=false):
	if sleep_timer.is_inside_tree() == false: return
	
	if (
		activation == true and (get_tree().current_scene.LEVEL_TYPE == 1 or get_tree().current_scene.FORCE_SLEEP_UNTIL_VISIBLE == false) 
		or has_awoken == true
		or is_on_screen() == true
	):
		has_awoken = true
		if active != true:
			emit_signal("awoken")
		sleep_timer.stop()
		active = true
		entity.set_physics_process(true)
		entity.set_process(true)
		visible = true
		for child in entity.get_children():
			if child.get_name() != "sleeper":
				child.set_physics_process(true)
				child.set_process(true)
				if child is Sprite: child.visible = true
	elif sleep_timer.time_left != sleep_delay:
		sleep_timer.start()

func _on_sleeper_screen_entered() -> void:
	set_activation(true)

func _on_sleeper_screen_exited() -> void:
	if brain == null or entity.input_vector == Vector2.ZERO:
		set_activation(false)
	elif brain.targets == []:
		set_activation(false)

func target_found():
	set_activation(true)

func target_lost():
	if is_on_screen() == false:
		set_activation(false)

func health_changed(_type, _result, _net):
	set_activation(true)

func _on_sleep_timer_timeout() -> void:
	active = false
	entity.set_physics_process(false)
	entity.set_process(false)
	entity.velocity = Vector2.ZERO
	visible = false
	for child in entity.get_children():
		if child.get_name() != "sleeper":
			child.set_physics_process(false)
			child.set_process(false)
			if child is Sprite: visible = false
	emit_signal("slept")
