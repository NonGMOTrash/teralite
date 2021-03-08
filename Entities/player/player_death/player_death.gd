extends Sprite

var waiting = false
var simple_mode = true # just plays the animation; for the death of other players that aren't the main one
var death_message: String

onready var label = $CanvasLayer/Label

func _ready():
	label.text = death_message + "\n" + "Press [E] to retry."

func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	waiting = true
	
	if simple_mode == true:
		# PROBLEM_NOTE: \/ should maybe do this
		# $CanvasLayer.queue_free()
		$AnimationPlayer.play("dissappear")
		label.visible = false
		return
	
	label.visible = true

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		get_tree().reload_current_scene()
