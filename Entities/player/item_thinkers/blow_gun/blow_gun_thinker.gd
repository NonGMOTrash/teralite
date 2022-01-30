extends Thinker

export var cooldown_time: float
export var BLOW_DART: PackedScene

onready var cooldown := $cooldown

func _ready() -> void:
	cooldown.wait_time = cooldown_time

func get_ready():
	if cooldown.time_left == 0:
		return true
	else:
		return false

func primary():
	cooldown.start()
	var blow_dart: Projectile = BLOW_DART.instance()
	blow_dart.setup(player, global.get_look_pos())
	refs.ysort.get_ref().add_child(blow_dart)
	
	global.emit_signal("update_item_info", # set a condition to null to hide it
		display_name, # current item
		null, # extra info
		cooldown.wait_time, # item bar max
		cooldown.time_left, # item bar value
		cooldown.wait_time # bar timer duration
	)

func _on_cooldown_timeout() -> void:
	global.emit_signal("update_item_info", # set a condition to null to hide it
		display_name, # current item
		null, # extra info
		null, # item bar max
		null, # item bar value
		null # bar timer duration
	)
