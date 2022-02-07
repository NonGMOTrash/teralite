extends Thinker

const SHINE = preload("res://Entities/Attacks/Melee/shine/shine.tscn")

export(float, 0.01, 1.0) var SHOOT_COOLDOWN: float
export(float, 0.01, 10.0) var SHINE_COOLDOWN: float
export var MAGIC: PackedScene

onready var shoot_cooldown = $shoot_cooldown
onready var shine_cooldown = $shine_cooldown
onready var held_item := get_parent().components["held_item"] as Node
onready var player_hurtbox: Area2D = player.components["hurtbox"]

var shine: Melee

func _ready():
	shoot_cooldown.wait_time = SHOOT_COOLDOWN
	shine_cooldown.wait_time = SHINE_COOLDOWN

func get_ready():
	return true

func primary():
	if shoot_cooldown.time_left == 0:
		var magic: Projectile = MAGIC.instance()
		magic.setup(player, global.get_look_pos())
		refs.ysort.add_child(magic)
		shoot_cooldown.start()
		held_item.animation.play("test_slash", -1, -2, true)

func secondary():
	if shine_cooldown.time_left == 0:
		shine = SHINE.instance()
		shine.position = player.global_position
		shine.setup(player, global.get_look_pos())
		shine.connect("reflect", self, "skip_shine_cooldown")
		refs.ysort.call_deferred("add_child", shine)
		yield(shine, "ready")
		shine.hitbox.connect("hit", self, "skip_shine_cooldown_hit")
		
		shine_cooldown.wait_time = SHINE_COOLDOWN
		shine_cooldown.start()

func skip_shine_cooldown():
	var animation: AnimationPlayer = shine.animation
	shine_cooldown.wait_time = animation.current_animation_length - animation.current_animation_position
	shine_cooldown.start()

func skip_shine_cooldown_hit(_arg1, _arg2):
	var animation: AnimationPlayer = shine.animation
	shine_cooldown.wait_time = animation.current_animation_length - animation.current_animation_position
	shine_cooldown.start()
