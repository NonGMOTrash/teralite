extends Sprite

var waiting = false
var simple_mode = true # just plays the animation; for the death of other players that aren't the main one
var death_message: String
var pressed := false

onready var label: Label = $CanvasLayer/Label

func _ready():
	if simple_mode == true:
		label.visible = false
	else:
		label.text = ""
		#OS.delay_msec((5/60.0) * 1000)
		label.text = death_message + "\n" + "press [E] to retry"

func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	waiting = true
	
	if simple_mode == true:
		# PROBLEM_NOTE: \/ should maybe do this
		# $CanvasLayer.queue_free()
		$AnimationPlayer.play("dissappear")
		label.visible = false
		return
	else:
		label.visible = true

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		pressed = true
	elif Input.is_action_just_released("interact") and pressed == true:
		set_process(false)
		label.visible = false
		refs.transition.exit()
		global.total_time += refs.stopwatch.time
		yield(refs.transition, "finished")
		get_tree().reload_current_scene()

func _process(_delta):
	# PROBLEM_NOTE: this is kinda bad because it's checked every frame
	if refs.pause_menu.visible == true:
		label.visible = false
	elif simple_mode == false:
		label.visible = true
