extends Control

const A_HUB = "res://Levels/A/A_hub.tscn"

onready var header =$area/header/label
onready var time = $area/stats/time/value
onready var health = $area/stats/health/value

var level_name: String = "Level"
var destination: PackedScene
var time_value: float = 0.0
var health_value: float = 0.0

func _ready() -> void:
	header.text = "%s Completed" % level_name
	health.text = str(health_value * 100.0) + "%"
	
	var minute = int(floor(time_value / 60))
	var second = int(floor(time_value - (minute * 60)))
	var tenth = stepify(time_value - ((minute*60) + second), 0.1) * 10
	if tenth == 10: tenth = 0 # PROBLEM_NOTE: might be the wrong way to display it but im not sure
	
	if second < 10: 
		second = str(second)
		second = "0"+second
	
	time.text = (
		str(minute) +
		":" +
		str(second) +
		"." +
		str(tenth)
		)

func _input(_event):
	if Input.is_action_just_pressed("interact"):
		if destination == null:
			push_error("destination == null")
			queue_free()
			get_tree().change_scene_to(load(A_HUB))
		else:
			queue_free()
			get_tree().change_scene_to(destination)
