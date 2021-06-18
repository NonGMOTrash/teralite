extends Thinker

export(float) var reload_time := 1.6
export(float) var reload_slow := 1.5
export(AudioStream) var reload_sound: AudioStream

onready var reload: Timer = $reload
onready var held_item_sprite: Sprite = player.components["held_item"].sprite

var loaded := true
var slowness: Status_Effect

func _init() -> void:
	res.allocate("bolt")

func _ready() -> void:
	reload.wait_time = reload_time
	held_item_sprite.hframes = 2
	held_item_sprite.vframes = 1
	held_item_sprite.frame = 1

func get_ready() -> bool:
	return loaded

func primary():
	.primary()
	if get_ready() == false:
		if reload.time_left == 0:
			reload()
		return
	
	quick_spawn("bolt")
	loaded = false
	global.emit_signal("update_item_info", # set a condition to null to hide it
		my_item, # current item
		str(int(loaded)) + " / " + str(1), # extra info 
		null, # item bar max 
		null, # item bar value 
		null # bar timer duration
	)
	held_item_sprite.frame = 0

func reload():
	.reload()
	if reload.time_left > 0 or loaded == true: return
	sound_player.play_sound("reload")
	reload.start()
	global.emit_signal("update_item_info", # set a condition to null to hide it
		my_item, # current item
		null, # extra info 
		reload.wait_time, # item bar max 
		reload.time_left, # item bar value 
		reload.wait_time # bar timer duration
	)
	
	player.components["stats"].add_status_effect("slowness", reload_time, reload_slow)

func _on_reload_timeout() -> void:
	loaded = true
	global.emit_signal("update_item_info", # set a condition to null to hide it
		my_item, # current item
		str(int(loaded)) + " / " + str(1), # extra info 
		null, # item bar max 
		null, # item bar value 
		null # bar timer duration
	)
	held_item_sprite.frame = 1

func selected():
	.selected()
	global.emit_signal("update_item_info", # set a condition to null to hide it
		my_item, # current item
		str(int(loaded)) + " / " + str(1), # extra info 
		null, # item bar max 
		null, # item bar value 
		null # bar timer duration
	)
	update_cursor()
	_update_held_item()

func unselected():
	reload.stop()
