extends Node2D

onready var label = $Node2D/Label
onready var sprite = $Area2D/Sprite

export var LEVEL := "level"
export var STAR_REQUIREMENT = 0

var player = null
var pressed = false

func _ready() -> void:
	var txt
	
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
			var missing_stars = STAR_REQUIREMENT - global.stars
			if missing_stars == 1:
				txt = "You need 1 more star"
			else:
				txt = "You need %s more stars" % missing_stars
			
		1, 2, 3: txt = "Press [E] to enter"
	
	var death_txt = "Deaths: NA"
	if LEVEL in global.level_deaths:
		death_txt = "Deaths: %s" % global.level_deaths[LEVEL]
	
	var time_txt = "Best Time: NA"
	if LEVEL in global.level_times:
		var time = global.level_times[LEVEL]
		var minute = int(floor(time / 60))
		var second = int(floor(time - (minute * 60)))
		var tenth = stepify(time - ((minute*60) + second), 0.1) * 10
		if tenth == 10: 
			tenth = 0
		if second < 10: 
			second = str(second)
			second = "0"+second
		
		var final_time = (
			str(minute) +
			":" +
			str(second) +
			"." +
			str(tenth)
			)
		time_txt = "Best Time: %s" % final_time
	
	label.text = (
		LEVEL + "\n" +
		txt + "\n" +
		death_txt + "\n" +
		time_txt
	)
	
	label.visible = false

func _input(event: InputEvent) -> void:
	if player == null: return
	if global.stars < STAR_REQUIREMENT: return
	
	if Input.is_action_just_pressed("interact"):
		pressed = true
		return
	
	if Input.is_action_just_released("interact") and pressed == true:
		global.player_hub_pos = global_position
		get_tree().change_scene("res://Levels/%s/%s.tscn" % [get_tree().current_scene.LETTER, LEVEL])

func _on_Area2D_body_entered(body: Node) -> void:
	if global.nodes["player"] == null: return
	elif body != get_node(global.nodes["player"]) : return
	player = body
	label.visible = true

func _on_Area2D_body_exited(body: Node) -> void:
	if global.nodes["player"] == null: return
	elif body != get_node(global.nodes["player"]) : return
	player = null
	label.visible = false
