extends Thinker

const SHINE = preload("res://Entities/Attacks/Melee/shine/shine.tscn")

export(float, 0.01, 1.0) var SHOOT_COOLDOWN: float
export(float, 0.01, 1.0) var SHINE_COOLDOWN: float
export(float, 0.01, 1.0) var SHINE_INVINCIBILITY: float

onready var cooldown = $cooldown
onready var invincibility := $invincibility
onready var held_item := get_parent().components["held_item"] as Node
onready var player_hurtbox: Area2D = player.components["hurtbox"]

var shine: Melee

func _init():
	res.allocate("magic")
	res.allocate("shine")

func _ready():
	cooldown.start()

func get_ready():
	if cooldown.time_left > 0:
		return false
	else:
		return true

func primary():
	quick_spawn("magic")
	cooldown.wait_time = SHOOT_COOLDOWN
	cooldown.start()
	held_item.animation.play("test_slash", -1, -2, true)

func secondary():
	quick_spawn("shine")
	cooldown.wait_time = SHINE_COOLDOWN
	cooldown.start()
	player_hurtbox.set_deferred("monitoring", false)
	player_hurtbox.set_deferred("monitorable", false)
	invincibility.start()
#	old, broken (?) code for holding a single shine
#	if Input.is_action_just_pressed("secondary_action"):
#		shine = SHINE.instance()
#		shine.setup(get_parent(), get_parent().get_global_mouse_position())
#		get_parent().get_parent().add_child(shine)
#		cooldown.wait_time = SHINE_COOLDOWN
#		cooldown.start()
#	elif Input.is_action_just_released("secondary_action"):
#		shine.animation.connect("animation_finished", shine, "queue_free")

func _on_invincibility_timeout() -> void:
	player_hurtbox.set_deferred("monitoring", true)
	player_hurtbox.set_deferred("monitorable", true)
