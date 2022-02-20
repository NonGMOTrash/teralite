extends Thinker

export var attack_cooldown := 0.45
export var BEAM: PackedScene

onready var cooldown := $cooldown as Timer
onready var player_hurtbox: Area2D = player.components["hurtbox"]
onready var player_sprite: Sprite = player.components["entity_sprite"]

var can_counter := false

func get_ready():
	if cooldown.time_left > 0:
		return false
	else:
		return true

func primary():
	.primary()
	var beam: Melee = BEAM.instance()
	beam.setup(player, global.get_look_pos())
	refs.ysort.add_child(beam)
	cooldown.wait_time = attack_cooldown
	cooldown.start()
