extends Entity

const LASER := preload("res://Entities/Attacks/Projectile/laser/laser.tscn")

onready var sprite: Sprite = $entity_sprite
onready var shadow: Sprite = $entity_sprite/shadow
onready var animation: AnimationPlayer = $AnimationPlayer

var saved_target: Entity

func _physics_process(_delta: float) -> void:
	if input_vector.x > 0.3:
		sprite.rotation_degrees += abs(velocity.x) / 50
		if sprite.rotation_degrees > 30:
			sprite.rotation_degrees = 30
	elif input_vector.x < -0.3:
		sprite.rotation_degrees -= abs(velocity.x) / 50
		if sprite.rotation_degrees < -30:
			sprite.rotation_degrees = -30
	else:
		sprite.rotation_degrees = move_toward(sprite.rotation_degrees, 0, abs(sprite.rotation_degrees) / 10)
	# it looks weird to have the shadow be moved by the rotation
	shadow.global_position = sprite.global_position + Vector2(0, 15)

func _on_action_lobe_action(action, target) -> void:
	saved_target = target
	animation.play("warning")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if not is_instance_valid(saved_target):
		return
	var laser: Projectile = LASER.instance()
	laser.collision_mask = 0
	laser.setup(self, saved_target.global_position)
	refs.ysort.add_child(laser)
