extends Projectile

onready var projectile_field: Area2D = $projectile_field
onready var animation: AnimationPlayer = $AnimationPlayer

var impacted := false

func _on_projectile_field_body_entered(body: Node) -> void:
	if body is Projectile and body != self:
		body.collided()
		sound.play_sound("zap")

func death():
	if not impacted:
		collided()
	else:
		.death()

func collided():
	velocity *= 0.2
	animation.play("impact")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "impact":
		impacted = true
		.collided()
