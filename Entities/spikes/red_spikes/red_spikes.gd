extends Entity

onready var activation := $activation as Area2D
onready var animation := $AnimationPlayer as AnimationPlayer

func _ready():
	$pokey.visible = false

func _on_activation_area_entered(_area: Area2D) -> void:
	if animation.is_playing() == true: return
	animation.play("spikes")
	activation.queue_free()
