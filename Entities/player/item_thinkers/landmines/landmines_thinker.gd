extends Thinker

const LANDMINE := preload("res://Entities/landmine/landmine.tscn")

export var max_mines: int
export var mines: int

onready var sound: Node = $sound_player

func _ready() -> void:
	mines -= times_used
	global.emit_signal("update_item_info", # set a condition to null to hide it
		display_name, # current item
		str(mines) + " / " + str(max_mines), # extra info 
		null, # item bar max 
		null, # item bar value 
		null  # bar timer duration
	)

func primary():
	if mines == 0:
		return
	
	var landmine: Entity = LANDMINE.instance()
	landmine.position = player.global_position
	landmine.faction = "player"
	refs.ysort.add_child(landmine)
	mines -= 1
	times_used += 1
	sound_player.play_sound("place")
	
	if mines == 0:
		delete()
		return
	
	global.emit_signal("update_item_info", # set a condition to null to hide it
		display_name, # current item
		str(mines) + " / " + str(max_mines), # extra info 
		null, # item bar max 
		null, # item bar value 
		null  # bar timer duration
	)

func selected():
	.selected()
	global.emit_signal("update_item_info", # set a condition to null to hide it
		display_name, # current item
		str(mines) + " / " + str(max_mines), # extra info 
		null, # item bar max 
		null, # item bar value 
		null  # bar timer duration
	)
