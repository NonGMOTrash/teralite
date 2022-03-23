extends Thinker

const KEYBLAST := preload("res://Entities/Attacks/Projectile/keyblast/keyblast.tscn")

onready var cooldown: Timer = $cooldown

func get_ready() -> bool:
	return cooldown.time_left == 0

func primary():
	var keyblast: Projectile = KEYBLAST.instance()
	keyblast.setup(player, player.get_global_mouse_position())
	refs.ysort.add_child(keyblast)
	cooldown.start()
