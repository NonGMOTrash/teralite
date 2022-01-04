extends TextureRect

onready var animation: AnimationPlayer = $AnimationPlayer

signal finished

func _init() -> void:
	refs.transition = weakref(self)

func _ready():
	visible = true
	animation.play("enter")

func exit():
	visible = true
	animation.play("exit")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	emit_signal("finished")
	visible = false
