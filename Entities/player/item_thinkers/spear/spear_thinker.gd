extends Thinker

export(float, 0.01, 2.0) var cooldown_time: float
export var POKE: PackedScene
export var THROWN_SPEAR: PackedScene

onready var cooldown := $cooldown as Timer

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
	var poke: Melee = POKE.instance()
	poke.setup(player, global.get_look_pos())
	refs.ysort.add_child(poke)
	cooldown.start()

func secondary():
	.secondary()
	var thrown_spear: Projectile = THROWN_SPEAR.instance()
	thrown_spear.setup(player, global.get_look_pos())
	refs.ysort.add_child(thrown_spear)
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
	
	delete()
