extends Thinker

export(float, 0.01, 2.0) var cooldown_time: float

onready var cooldown := $cooldown as Timer

func _init():
	res.allocate("poke")
	res.allocate("thrown_spear")

func _ready() -> void:
	cooldown.wait_time = cooldown_time
	cooldown.start()

func get_ready():
	if cooldown.time_left > 0:
		return false
	else:
		return true

func primary():
	.primary()
	quick_spawn("poke")
	cooldown.start()

func secondary():
	.secondary()
	quick_spawn("thrown_spear")
	player.inventory[global.selection] = null
	player.held_item.sprite.texture = null
	player.held_item.sprite.rotation_degrees = 0
	
	global.emit_signal("update_item_info", # set a condition to null to hide it
		null, # current item
		null, # extra info 
		null, # item bar max 
		null, # item bar value 
		null # bar timer duration
	)
	if player.get_name() == "player":
		global.emit_signal("update_item_bar", get_parent().inventory)
	
	queue_free()
