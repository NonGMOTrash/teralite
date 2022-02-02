extends ColorRect

const TITLE = preload("res://UI/title_screen/title_screen.tscn")
const ERROR_PNG = preload("res://UI/intro/error.png")
const ERROR_SFX = preload("res://UI/intro/os_error.wav")
const HIT_EFFECT = preload("res://Effects/hit_effect/hit_effect.tscn")
const HIT_SFX = preload("res://Entities/Attacks/Melee/slash/slash_kill.wav")

export(Array) var animation_queue: Array

onready var animation: AnimationPlayer = $AnimationPlayer
onready var sound_player: Node = $sound_player
onready var wtf: Control = $wtf

func _input(event: InputEvent):
	if event is InputEventKey or event is InputEventJoypadButton or event is InputEventMouseButton:
		if event.pressed:
			get_tree().change_scene_to(TITLE)

func _ready() -> void:
	animation.play(animation_queue[0])
	animation_queue.pop_front()
	global.set_discord_activity("opening the game")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if animation_queue.size() == 0:
		
		get_tree().change_scene_to(TITLE)
	else:
		animation.play(animation_queue[0])
		animation_queue.pop_front()

func wtf(pos: Vector2 = Vector2( rand_range(80, 280), rand_range(50, 165) )):
	OS.request_attention()
	sound_player.create_sound(ERROR_SFX, true)
	var error:Sprite = Sprite.new()
	error.texture = ERROR_PNG
	error.scale = Vector2(0.5, 0.5)
	wtf.add_child(error)
	error.global_position = pos

func hit():
	sound_player.create_sound(HIT_SFX, true)
	
	var target
	while not target is Sprite:
		target = wtf.get_children()[randi() % wtf.get_child_count()-1]
	
	for _i in range(1, 5):
		var hit = HIT_EFFECT.instance()
		wtf.add_child(hit)
		hit.global_position = target.global_position + Vector2(
			rand_range(-80, 80), 
			rand_range(-45, 45)
		)
	
	target.queue_free()

func add_lol_msg():
	var lol = Label.new()
	lol.theme = self.theme
	lol.text = "lol"
	lol.show_behind_parent = true
	wtf.add_child(lol)
	lol.anchor_right = 0.5
	lol.anchor_left = 0.5
	lol.anchor_bottom = 0.5
	lol.anchor_top = 0.5
