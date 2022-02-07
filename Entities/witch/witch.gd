extends Entity

const BLOW_DART := preload("res://Entities/Attacks/Projectile/blow_dart/blow_dart.tscn")

export var attack_cooldown: float

var stored_target_pos: Vector2

onready var animation := $AnimationPlayer
onready var held_item := $held_item

func _ready() -> void:
	$brain/action_lobe/attack.COOLDOWN = attack_cooldown
	held_item.animation.connect("animation_finished", self, "attack")

func _physics_process(delta: float) -> void:
	if input_vector == Vector2.ZERO:
		animation.play("stand")
	else:
		animation.play("walk")

func _on_action_lobe_action(action, target) -> void:
	stored_target_pos = target.global_position
	held_item.TARGETING = held_item.TT.MANUAL
	held_item.animation.play("warn")

func attack(_finished_animation: String) -> void:
	var blow_dart: Projectile = BLOW_DART.instance()
	blow_dart.setup(self, stored_target_pos)
	blow_dart.global_position = self.global_position
	refs.ysort.call_deferred("add_child", blow_dart)
	held_item.TARGETING = held_item.TT.BRAIN_TARGET
