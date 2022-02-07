extends Thinker

export var reload_time: float
export var ROCKET: PackedScene

onready var reload: Timer = $reload
onready var spawner: Node = $spawner # used for muzzle flash

var loaded := true

func _ready() -> void:
	reload.wait_time = reload_time

func _on_reload_timeout() -> void:
	loaded = true
	
	global.emit_signal("update_item_info", # set a condition to null to hide it
		display_name, # current item
		str(int(loaded)) + " / 1", # extra info 
		null, # item bar max 
		null, # item bar value 
		null # bar timer duration
	)

func get_ready():
	return loaded

func selected():
	.selected()
	global.emit_signal("update_item_info", # set a condition to null to hide it
		display_name, # current item
		str(int(loaded)) + " / 1", # extra info 
		null, # item bar max 
		null, # item bar value 
		null # bar timer duration
	)

func unselected():
	reload.stop()

func primary():
	.primary()
	if get_ready() == false:
		if reload.time_left == 0:
			reload()
		return
	
	var rocket: Projectile = ROCKET.instance()
	rocket.setup(player, global.get_look_pos())
	refs.ysort.add_child(rocket)
	loaded = false
	reload.stop()
	global.emit_signal("update_item_info", # set a condition to null to hide it
		display_name, # current item
		"0 / 1", # extra info 
		null, # item bar max 
		null, # item bar value 
		null # bar timer duration
	)
	spawner.spawn()

func reload():
	.reload()
	if reload.time_left > 0:
		return
	reload.start()
	global.emit_signal("update_item_info", # set a condition to null to hide it
		display_name, # current item
		null, # extra info 
		reload.wait_time, # item bar max 
		reload.time_left, # item bar value 
		reload.wait_time # bar timer duration
	)
	sound_player.play_sound("reload")
