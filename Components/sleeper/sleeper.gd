extends VisibilityEnabler2D

onready var sleep_timer = $sleep_timer

export(float, 0.01, 60.0) var sleep_delay = 3.0

var active = true

var brain

func _on_sleeper_tree_entered() -> void:
	get_parent().components["sleeper"] = self

func _ready() -> void:
	if is_on_screen() == false: _on_sleep_timer_timeout()
	
	brain = get_parent().components["brain"]
	
	sleep_timer.wait_time = sleep_delay
	
	if brain == null: return
	brain.connect("found_target", self, "target_found")
	brain.connect("lost_target", self, "target_lost")

func set_activation(activation: bool):
	if sleep_timer.is_inside_tree() == false: return
	
	if activation == true: 
		sleep_timer.stop()
		active = true
		get_parent().set_physics_process(true)
		get_parent().set_process(true)
		visible = true
		for child in get_parent().get_children():
			if child.get_name() != "sleeper":
				child.set_physics_process(true)
				child.set_process(true)
				if child is Sprite: child.visible = true
	elif sleep_timer.time_left != sleep_delay:
		sleep_timer.start()

func _on_sleeper_screen_entered() -> void:
	set_activation(true)

func _on_sleeper_screen_exited() -> void:
	if brain == null or get_parent().input_vector == Vector2.ZERO:
		set_activation(false)
	elif brain.targets == []:
		set_activation(false)

func target_found():
	set_activation(true)

func target_lost():
	if is_on_screen() == false:
		set_activation(false)

func _on_sleep_timer_timeout() -> void:
	active = false
	get_parent().set_physics_process(false)
	get_parent().set_process(false)
	visible = false
	for child in get_parent().get_children():
		if child.get_name() != "sleeper":
			child.set_physics_process(false)
			child.set_process(false)
			if child is Sprite: visible = false
