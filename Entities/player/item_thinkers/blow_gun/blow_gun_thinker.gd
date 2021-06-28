extends Thinker

export var cooldown_time: float

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
	quick_spawn("blow_dart")
	
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
