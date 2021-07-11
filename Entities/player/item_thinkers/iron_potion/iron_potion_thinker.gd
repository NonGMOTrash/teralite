extends Thinker

export var resistance_level: int
export var slowness_level: float
export var duration: float

func primary():
	player.components["stats"].add_status_effect("resistance", duration, resistance_level)
	player.components["stats"].add_status_effect("slowness", duration, slowness_level)
	
	queue_free()
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
		global.emit_signal("update_item_bar", player.inventory)
	
	sound_player.play_sound("drink")

func secondary():
	quick_spawn("thrown_iron_potion")
	
	queue_free()
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
		global.emit_signal("update_item_bar", player.inventory)
