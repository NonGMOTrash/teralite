extends Thinker

const SYRINGE := preload("res://Entities/Attacks/Melee/syringe/syringe.tscn")

export var cooldown_time: float
export var doses: int

onready var cooldown: Timer = $cooldown
onready var max_doses: int = doses

func _ready() -> void:
	cooldown.wait_time = cooldown_time
	if global.selection == slot:
		selected()

func get_ready():
	if cooldown.time_left > 0:
		return false
	else:
		return true

func primary():
	var syringe: Melee = SYRINGE.instance()
	syringe.global_position = player.global_position
	syringe.setup(player, global.get_look_pos())
	syringe.find_node("hitbox").connect("hit", self, "syringe_hit")
	refs.ysort.add_child(syringe)
	cooldown.start()

func selected():
	.selected()
	global.emit_signal("update_item_info", # set a condition to null to hide it
		display_name, # current item
		"%s / %s" % [doses, max_doses], # extra info
		null, # item bar max
		null, # item bar value
		null # bar timer duration
	)

func syringe_hit(_area, _type):
	doses -= 1
	if doses <= 0:
		delete()
	else:
		global.emit_signal("update_item_info", # set a condition to null to hide it
			display_name, # current item
			"%s / %s" % [doses, max_doses], # extra info
			null, # item bar max
			null, # item bar value
			null # bar timer duration
		)
