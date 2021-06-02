extends Thinker

onready var cooldown = $cooldown
onready var held_item := get_parent().components["held_item"] as Node

func _init():
	res.allocate("magic")

func _ready():
	cooldown.start()

func get_ready():
	if cooldown.time_left > 0:
		return false
	else:
		return true

func primary():
#	var magic = MAGIC.instance()
#	magic.setup(get_parent(), get_parent().get_global_mouse_position())
#	get_parent().get_parent().add_child(magic)
	quick_spawn("magic")
	cooldown.start()
	if held_item.sprite.flip_v == true:
		held_item.animation.play("test_slash", -1, -2, true)
	else:
		held_item.animation.play("test_slash", -1, -2, true)

func secondary():
	pass
