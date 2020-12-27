extends VisibilityEnabler2D

onready var sleep_timer = $sleep_timer

var active = true

var brain

func _on_sleeper_tree_entered() -> void:
	get_parent().components["sleeper"] = self

func _ready() -> void:
	set_activation(is_on_screen())
	
	brain = get_parent().components["brain"]
	
	if brain == null: return
	brain.connect("found_target", self, "target_found")
	brain.connect("lost_target", self, "target_lost")

func set_activation(boolean: bool = true):
	active = boolean
	get_parent().set_physics_process(boolean)
	get_parent().set_process(boolean)
	visible = boolean
	for i in get_parent().get_child_count():
		var child = get_parent().get_children()[i]
		if child.get_name() != "sleeper":
			child.set_physics_process(boolean)
			child.set_process(boolean)
			visible = boolean
	
	if boolean == true: sleep_timer.start()
	else: sleep_timer.stop()

func _on_sleeper_screen_entered() -> void:
	set_activation(true)

func _on_sleeper_screen_exited() -> void:
	if brain == null:
		set_activation(false)
	elif brain.targets == []:
		set_activation(false)

func target_found():
	set_activation(true)

func target_lost():
	if is_on_screen() == false:
		set_activation(false)

func _on_sleep_timer_timeout() -> void:
	if is_on_screen() == false:
		set_activation(false)
