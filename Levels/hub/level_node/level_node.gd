extends Node2D

export var LEVEL := "level"
export var STAR_REQUIREMENT = 0
export var WORLD_ENTRANCE := false
export var CUSTOM_SCENE_PATH := ""
export var REQUIRED_LEVEL := ""

var player = null
var pressed := false
var open := false

onready var info = $Node2D/info
onready var header = $Node2D/info/header
onready var deaths = $Node2D/info/HBoxContainer/deaths
onready var time = $Node2D/info/HBoxContainer/time
onready var sprite = $Area2D/Sprite

func _ready() -> void:
	if (
		global.stars >= STAR_REQUIREMENT and
		(REQUIRED_LEVEL == "" or REQUIRED_LEVEL in global.cleared_levels)
	):
		open = true
	
	info.visible = false
	var enter_text: String
	
	if WORLD_ENTRANCE == true:
		if REQUIRED_LEVEL != "" and not REQUIRED_LEVEL in global.cleared_levels:
			enter_text = "complete %s first" % REQUIRED_LEVEL
		else:
			var missing_stars: int = STAR_REQUIREMENT - global.stars
			if missing_stars < 1: enter_text = "press [E] to enter"
			elif missing_stars == 1: enter_text = "you need 1 more star"
			elif missing_stars > 1: enter_text = "you need %s more stars" % missing_stars
		
		header.text = LEVEL.to_lower() + "\n" + enter_text
		return
	
	if global.stars < STAR_REQUIREMENT: 
		sprite.frame = 0
	elif global.stars >= STAR_REQUIREMENT: 
		if global.cleared_levels.has(LEVEL):
			if global.perfected_levels.has(LEVEL):
				sprite.frame = 3
			else:
				sprite.frame = 2
		else:
			sprite.frame = 1
	
	match sprite.frame:
		0:
			if REQUIRED_LEVEL != "" and not REQUIRED_LEVEL in global.cleared_levels:
				enter_text = "complete %s first" % REQUIRED_LEVEL
			else:
				var missing_stars = STAR_REQUIREMENT - global.stars
				if missing_stars == 1:
					enter_text = "you need 1 more star"
				else:
					enter_text = "you need %s more stars" % missing_stars
		1, 2, 3:
			enter_text = "press [E] to enter"
	
	header.text = LEVEL.to_lower() + "\n" + enter_text
	
	if LEVEL in global.level_deaths:
		deaths.text = str(global.level_deaths[LEVEL])
	else:
		deaths.text = "NA"
	
	if LEVEL in global.level_times:
		time.text = global.sec_to_time(global.level_times[LEVEL])

func _input(event: InputEvent) -> void:
	if player == null or not open:
		return
	
	if Input.is_action_just_pressed("interact"): #and player.input_vector == Vector2.ZERO:
		pressed = true
		return
	
	if Input.is_action_just_released("interact") and pressed == true:
		global.player_hub_pos[get_tree().current_scene.LETTER] = global_position + Vector2(0, 16)
		refs.transition.get_ref().exit()
		yield(refs.transition.get_ref(), "finished")
		if CUSTOM_SCENE_PATH == "":
			get_tree().change_scene("res://Levels/%s/%s.tscn" % [get_tree().current_scene.LETTER, LEVEL])
		else:
			get_tree().change_scene(CUSTOM_SCENE_PATH)

func _on_Area2D_body_entered(body: Node) -> void:
	if refs.player.get_ref() == null: return
	elif body != refs.player.get_ref(): return
	player = body
	info.visible = true

func _on_Area2D_body_exited(body: Node) -> void:
	if refs.player.get_ref() == null: return
	elif body != refs.player.get_ref(): return
	player = null
	info.visible = false
