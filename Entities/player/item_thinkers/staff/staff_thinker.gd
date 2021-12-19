extends Thinker

const SHINE = preload("res://Entities/Attacks/Melee/shine/shine.tscn")

export(float, 0.01, 1.0) var SHOOT_COOLDOWN: float
export(float, 0.01, 10.0) var SHINE_COOLDOWN: float
export(float, 0.01, 10.0) var SHINE_COOLDOWN_FOLLOWUP: float

onready var shoot_cooldown = $shoot_cooldown
onready var shine_cooldown = $shine_cooldown
onready var held_item := get_parent().components["held_item"] as Node
onready var player_hurtbox: Area2D = player.components["hurtbox"]

var shine: Melee

func _init():
	res.allocate("magic")
	res.allocate("shine")

func _ready():
	shoot_cooldown.wait_time = SHOOT_COOLDOWN
	shine_cooldown.wait_time = SHINE_COOLDOWN

func get_ready():
	return true

func primary():
	if shoot_cooldown.time_left == 0:
		quick_spawn("magic")
		shoot_cooldown.start()
		held_item.animation.play("test_slash", -1, -2, true)

func secondary():
	if shine_cooldown.time_left == 0:
		var shine: Melee = res.aquire_attack("shine")
		shine.position = player.global_position
		shine.setup(player, player.get_global_mouse_position())
		shine.connect("reflect", self, "skip_shine_cooldown")
		refs.ysort.get_ref().call_deferred("add_child", shine)
		
		shine_cooldown.wait_time = SHINE_COOLDOWN
		shine_cooldown.start()

func skip_shine_cooldown():
	if shine_cooldown.time_left > SHINE_COOLDOWN_FOLLOWUP:
		shine_cooldown.wait_time = SHINE_COOLDOWN_FOLLOWUP
		shine_cooldown.start()
