extends Entity

onready var animation = $AnimationPlayer

func _ready() -> void:
	animation.stop()
	$pokey.frame = 0
	$hitbox/CollisionShape2D.disabled = true

func _on_delay_timer_timeout() -> void:
	animation.play("spikes")
