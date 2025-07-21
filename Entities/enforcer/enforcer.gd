extends Entity

const KEYBLAST := preload("res://Entities/Attacks/Projectile/keyblast/keyblast.tscn")

export var warnings: int = 2

onready var animation: AnimationPlayer = $AnimationPlayer
onready var held_item: Node2D = $held_item

var stored_target: Entity

func _process(delta: float) -> void:
	if input_vector == Vector2.ZERO:
		animation.stop()
	else:
		animation.play("move")

func _on_action_lobe_action(action, target) -> void:
	for i in warnings:
		held_item.animation.queue("warn")
	stored_target = target
	
	if target.truName == "player":
		var length: float = held_item.animation.get_animation("warn").length * warnings
		get_tree().create_timer(length-0.5).connect("timeout", self, "attack_flash")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if held_item.animation.get_queue().size() == 0 and is_instance_valid(stored_target):
		var keyblast: Projectile = KEYBLAST.instance()
		keyblast.setup(self, stored_target.global_position)
		refs.ysort.add_child(keyblast)
