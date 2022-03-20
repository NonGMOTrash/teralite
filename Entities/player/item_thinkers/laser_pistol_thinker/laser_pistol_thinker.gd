extends Thinker

const LASER := preload("res://Entities/Attacks/Projectile/laser/laser.tscn")

onready var cooldown: Timer = $cooldown

func get_ready() -> bool:
	return cooldown.time_left == 0

func primary():
	var laser: Projectile = LASER.instance()
	laser.setup(player, player.get_global_mouse_position())
	refs.ysort.add_child(laser)
	cooldown.start()
