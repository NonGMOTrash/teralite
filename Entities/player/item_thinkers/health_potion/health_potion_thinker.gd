extends Thinker

export(int, 0, 99) var healing: int
export var THROWN_HEALTH_POTION: PackedScene

func primary():
	player.components["stats"].change_health(healing, 0, "heal")
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
	if get_parent().get_name() == "player":
		global.emit_signal("update_item_bar", get_parent().inventory)
	
	sound_player.play_sound("drink")

func secondary():
	var thrown_health_potion: Projectile = THROWN_HEALTH_POTION.instance()
	thrown_health_potion.setup(player, global.get_look_pos())
	refs.ysort.get_ref().add_child(thrown_health_potion)
	
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
		global.emit_signal("update_item_bar", get_parent().inventory)
